//  DiaryMainView.swift
//  Divary
//
//  Created by ㄱㄷㅇㄴㅇ on 7/6/25.
//

import SwiftUI
import PhotosUI
import RichTextKit

enum DiaryFooterBarType {
    case main, textStyle, fontSize, alignment, fontFamily, sticker
}

struct DiaryMainView: View {
    @Environment(\.diContainer) private var di
    @State private var didInject = false
    
    @Bindable var viewModel: DiaryMainViewModel
    
    let diaryLogId: Int
    
    @FocusState private var isRichTextEditorFocused: Bool
    @State private var footerBarType: DiaryFooterBarType = .main
    
    @State private var navigateToImageSelectView = false
    @State private var FramedImageSelectList: [FramedImageContent] = []
    
    @Binding var showCanvas: Bool
    @State private var currentOffsetY: CGFloat = 0
    
    // 키보드 관리
    @State private var keyboardHeight: CGFloat = 0
    @State private var isKeyboardVisible: Bool = false
    @State private var keyboardAnimationDuration: Double = 0.25
    
    // 스크롤 관리 - 상태 추가
    @State private var scrollToBlockId: UUID?
    @State private var isScrolling: Bool = false
    @State private var pendingFocusBlockId: UUID?
    
    // 키보드 토글 방지를 위한 상태 추가
    @State private var isKeyboardStabilizing: Bool = false
    @State private var lastFocusChangeTime: Date = Date()
    @State private var keyboardStabilizationTimer: Timer?
    
    // 하단 여백 계산
    private var bottomPadding: CGFloat {
        return isKeyboardVisible ? keyboardHeight + 150 : 200
    }
    
    private func openImageSelect(with images: [FramedImageContent]) {
        FramedImageSelectList = images
        di.router.push(.imageSelect(viewModel: viewModel, framedImages: images))
    }
    
    @ViewBuilder
    private var activeFooterBar: some View {
        switch footerBarType {
        case .main:
            MainFooterBar(
                viewModel: viewModel,
                footerBarType: $footerBarType,
                isRichTextEditorFocused: $isRichTextEditorFocused,
                showCanvas: $showCanvas
            )
        case .textStyle:
            TextStyleFooterBar(
                viewModel: viewModel,
                footerBarType: $footerBarType
            )
        case .fontSize:
            FontSizeFooterBar(
                viewModel: viewModel,
                footerBarType: $footerBarType
            )
        case .alignment:
            FontAlignmentFooterBar(
                viewModel: viewModel,
                footerBarType: $footerBarType
            )
        case .fontFamily:
            FontFamilyFooterBar(
                viewModel: viewModel,
                footerBarType: $footerBarType
            )
        case .sticker:
            StickerFooterBar(footerBarType: $footerBarType)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            diaryMain
            activeFooterBar
        }
        .task {
            if !didInject {
                viewModel.inject(
                    diaryService: di.logDiaryService,
                    imageService: di.imageService,
                    token: KeyChainManager.shared.read(forKey: "accessToken") ?? ""
                )
                viewModel.loadFromServer(logId: diaryLogId)
                viewModel.recomputeCanSave()
                didInject = true
            }
        }
        .overlay(
            showCanvas ? DiaryCanvasView(
                viewModel: DiaryCanvasViewModel(showCanvas: $showCanvas, diaryId: diaryLogId),
                offsetY: currentOffsetY,
                initialDrawing: viewModel.savedDrawing,
                onSaved: { drawing, offset in
                    viewModel.commitDrawingFromCanvas(drawing, offsetY: offset, autosave: false)
                }
            )
            .ignoresSafeArea(.container, edges: .bottom)
            : nil
        )
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            handleKeyboardWillShow(notification)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            handleKeyboardWillHide()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ScrollToBlock"))) { notification in
            if let blockId = notification.object as? UUID {
                scrollToBlock(blockId)
            }
        }
        .onChange(of: isRichTextEditorFocused) { _, newValue in
            handleFocusChange(newValue)
        }
        .onChange(of: footerBarType) { oldType, newType in
            handleFooterBarChange(oldType: oldType, newType: newType)
        }
    }
    
    // MARK: - 푸터바 변경 처리
    
    private func handleFooterBarChange(oldType: DiaryFooterBarType, newType: DiaryFooterBarType) {
        if newType == .fontFamily {
            // 폰트 패밀리로 전환 시 키보드 숨기기
            DispatchQueue.main.async {
                self.isRichTextEditorFocused = false
            }
        } else if oldType == .fontFamily && viewModel.editingTextBlock != nil {
            // 폰트 패밀리에서 다른 곳으로 갈 때 편집 중이면 키보드 다시 표시
            DispatchQueue.main.async {
                self.isRichTextEditorFocused = true
            }
        }
    }
    
    // MARK: - 키보드 처리
    
    private func handleKeyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        // 키보드가 이미 표시 중이고 안정화 중이면 무시
        guard !isKeyboardStabilizing else { return }
        
        keyboardAnimationDuration = duration
        
        withAnimation(.easeOut(duration: duration)) {
            keyboardHeight = keyboardFrame.height
            isKeyboardVisible = true
        }
        
        // 키보드 표시 후 안정화 기간 설정
        startKeyboardStabilization()
    }
    
    private func handleKeyboardWillHide() {
        // 키보드가 안정화 중이고 포커스가 있다면 숨기기를 방지
        if isKeyboardStabilizing && isRichTextEditorFocused {
            return
        }
        
        withAnimation(.easeOut(duration: keyboardAnimationDuration)) {
            keyboardHeight = 0
            isKeyboardVisible = false
        }
    }
    
    // MARK: - 포커스 변화 처리
    
    private func handleFocusChange(_ isFocused: Bool) {
        let now = Date()
        let timeSinceLastChange = now.timeIntervalSince(lastFocusChangeTime)
        lastFocusChangeTime = now
        
        // 너무 빠른 포커스 변화는 무시 (0.5초 이내)
        if timeSinceLastChange < 0.5 && isKeyboardStabilizing {
            return
        }
        
        if isFocused {
            // 포커스를 받을 때 키보드 안정화 시작
            startKeyboardStabilization()
        } else {
            // 포커스를 잃을 때 지연 후 키보드 숨기기
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if !self.isRichTextEditorFocused {
                    self.stopKeyboardStabilization()
                }
            }
        }
    }
    
    // MARK: - 키보드 안정화 관리
    
    private func startKeyboardStabilization() {
        isKeyboardStabilizing = true
        keyboardStabilizationTimer?.invalidate()
        
        // 2초 후 안정화 상태 해제
        keyboardStabilizationTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            self.isKeyboardStabilizing = false
        }
    }
    
    private func stopKeyboardStabilization() {
        isKeyboardStabilizing = false
        keyboardStabilizationTimer?.invalidate()
        keyboardStabilizationTimer = nil
    }
    
    // MARK: - 스크롤 처리 - 상태 관리 강화
    
    private func scrollToBlock(_ blockId: UUID) {
        guard !isScrolling else { return }
        
        isScrolling = true
        
        // 키보드 상태에 따라 스크롤 지연 조정
        let scrollDelay = isKeyboardVisible ? 0.1 : 0.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + scrollDelay) {
            self.scrollToBlockId = blockId
        }
    }
    
    private func scrollToBlockWithFocus(_ blockId: UUID) {
        guard !isScrolling else { return }
        
        // 먼저 스크롤, 완료 후 포커스
        pendingFocusBlockId = blockId
        scrollToBlock(blockId)
    }
    
    private var diaryMain: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                ZStack {
                    GeometryReader { geometry in
                      Image("gridBackground")
                          .resizable(resizingMode: .tile)
                          .scaledToFill()
                          .frame(
                              width: geometry.size.width,
                              height: max(geometry.size.height, UIScreen.main.bounds.height)
                          )
                    }.ignoresSafeArea()
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.blocks) { block in
                            switch block.content {
                            case .text(let content):
                                if viewModel.editingTextBlock?.id == block.id {
                                    EditingTextBlockView(
                                        viewModel: viewModel,
                                        isRichTextEditorFocused: $isRichTextEditorFocused,
                                        content: content,
                                        shouldAutoFocus: footerBarType != .fontFamily
                                    )
                                    .id(block.id)
                                    .transition(.identity) // 부드러운 전환
                                } else {
                                    CustomAttributedTextView(attributedText: content.text)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .frame(maxWidth: .infinity)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 4)
                                        .background(Color.clear)
                                        .onTapGesture {
                                            startEditingBlock(block)
                                        }
                                        .id(block.id)
                                        .transition(.identity) // 부드러운 전환
                                }
                               
                            case .image(let framed):
                                FramedImageComponentView(framedImage: framed)
                                    .onTapGesture {
                                        viewModel.editingImageBlock = block
                                        openImageSelect(with: [framed])
                                    }
                                    .id(block.id)
                            }
                        }
                        
                        // 하단 여백
                        Spacer(minLength: bottomPadding)
                            .id("bottom-spacer") // 안정적인 참조를 위한 ID
                    }
                    .animation(.easeOut(duration: keyboardAnimationDuration), value: bottomPadding)
                    
                    if let drawing = viewModel.savedDrawing {
                        DrawingScreenView(drawing: drawing, offsetY: viewModel.drawingOffsetY)
                            .opacity(showCanvas ? 0 : 1)
                        GeometryReader { geo in
                            Color.clear
                                .preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .named("scroll")).origin.y)
                        }
                    }
                }
                .onChange(of: viewModel.selectedItems) { _, newItems in
                    guard !newItems.isEmpty else { return }
                    Task {/* @MainActor in*/
                        let dtos = await viewModel.makeFramedDTOs(from: newItems)
                        await MainActor.run {
                            FramedImageSelectList = dtos
                            if !dtos.isEmpty {
                                openImageSelect(with: dtos)
                            }
                            viewModel.selectedItems.removeAll()
                        }
                    }
                }
                .onChange(of: viewModel.editingTextBlock) { _, editingBlock in
                    if let block = editingBlock {
                        // 키보드가 표시되기를 기다린 후 스크롤
                        let delay = isKeyboardVisible ? 0.1 : 0.3
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            self.scrollToBlockWithFocus(block.id)
                        }
                    }
                }
                .onChange(of: scrollToBlockId) { _, blockId in
                    if let blockId = blockId {
                        // 키보드 상태에 따른 앵커 포인트와 애니메이션 조정
                        let anchor: UnitPoint = isKeyboardVisible ? .top : .center
                        let animationDuration = isKeyboardVisible ? 0.5 : 0.4
                        
                        // 키보드가 표시 중이면 추가 지연
                        let executionDelay = (isKeyboardVisible && !isKeyboardStabilizing) ? 0.2 : 0.0
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + executionDelay) {
                            withAnimation(.easeInOut(duration: animationDuration)) {
                                proxy.scrollTo(blockId, anchor: anchor)
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                                self.isScrolling = false
                                self.scrollToBlockId = nil
                                
                                // 스크롤 완료 후 대기 중인 포커스 처리
                                if let focusBlockId = self.pendingFocusBlockId {
                                    self.pendingFocusBlockId = nil
                                    if self.viewModel.editingTextBlock?.id == focusBlockId {
                                        // 키보드 상태에 따른 포커스 지연 조정
                                        let focusDelay = self.isKeyboardVisible ? 0.1 : 0.3
                                        DispatchQueue.main.asyncAfter(deadline: .now() + focusDelay) {
                                            self.isRichTextEditorFocused = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .task {
                    if viewModel.savedDrawing == nil {
                        viewModel.loadSavedDrawing(diaryId: diaryLogId)
                    }
                }
            }
            .disabled(showCanvas)
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                if !showCanvas {
                    currentOffsetY = -value
                }
            }
        }
    }
    
    // MARK: - 텍스트 편집 시작
    
    private func startEditingBlock(_ block: DiaryBlock) {
        // 이미 스크롤 중이거나 키보드 안정화 중이면 대기
        guard !isScrolling && !isKeyboardStabilizing else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.startEditingBlock(block)
            }
            return
        }
        
        // 키보드가 표시 중이면 먼저 숨기고 안정화 후 편집 시작
        if isKeyboardVisible {
            isRichTextEditorFocused = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.performEditingStart(block)
            }
        } else {
            performEditingStart(block)
        }
    }
    
    private func performEditingStart(_ block: DiaryBlock) {
        viewModel.startEditing(block)
        
        // 키보드 안정화 시작
        startKeyboardStabilization()
        
        // 편집 시작 후 스크롤과 포커스는 onChange에서 처리
    }
}

#Preview {
    PreviewWrapper()
}

private struct PreviewWrapper: View {
    @State private var vm = DiaryMainViewModel()
    @State private var showCanvas = false

    var body: some View {
        DiaryMainView(viewModel: vm, diaryLogId: 67, showCanvas: $showCanvas)
    }
}
