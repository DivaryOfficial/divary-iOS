//
//  DiaryMainView.swift
//  Divary
//
//  Created by 김나영 on 7/6/25.
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
    
//    @State private var viewModel = DiaryMainViewModel()
    @Bindable var viewModel: DiaryMainViewModel
    
    let diaryLogId: Int
    
    @FocusState private var isRichTextEditorFocused: Bool
    @State private var footerBarType: DiaryFooterBarType = .main
    
    @State private var navigateToImageSelectView = false
    @State private var FramedImageSelectList: [FramedImageContent] = []
    
//    @State var showCanvas: Bool = false
    @Binding var showCanvas: Bool
    @State private var currentOffsetY: CGFloat = 0
    
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
//        .task {
            .task {
            if !didInject {
                viewModel.inject(
                    diaryService: di.logDiaryService,   // DI에 이미 들어있음 :contentReference[oaicite:0]{index=0}
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
//                offsetY: viewModel.drawingOffsetY,
                initialDrawing: viewModel.savedDrawing,
                onSaved: { drawing, offset in
                    // 메인 뷰 즉시 업데이트
//                    viewModel.savedDrawing = drawing
//                    viewModel.drawingOffsetY = offset
                    viewModel.commitDrawingFromCanvas(drawing, offsetY: offset, autosave: false)
                }
            )
            .ignoresSafeArea(.container, edges: .bottom)
            : nil
        )
    }
    
    private var diaryMain: some View {
        ScrollView(.vertical) {
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
                                    content: content
                                )
                            } else {
                                CustomAttributedTextView(attributedText: content.text)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .layoutPriority(1)
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 4)
                                    .background(Color.clear)
                                    .onTapGesture {
                                        viewModel.startEditing(block)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            isRichTextEditorFocused = true
                                        }
                                    }
                            }
                           
                        case .image(let framed):
                            FramedImageComponentView(framedImage: framed)
                                .onTapGesture { // 이미지 탭 시 편집 진입
                                    viewModel.editingImageBlock = block
                                    openImageSelect(with: [framed])
//                                    FramedImageSelectList = [framed]
//                                    navigateToImageSelectView = true
                                }
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                
                if let drawing = viewModel.savedDrawing {
                    DrawingScreenView(drawing: drawing, offsetY: viewModel.drawingOffsetY)
                        .opacity(showCanvas ? 0 : 1)
//                        .accessibilityHidden(showCanvas)
//                        .allowsHitTesting(false)
                    
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .named("scroll")).origin.y)
                    }
                }
            }
            // MARK: - 사진 띄우기
            .onChange(of: viewModel.selectedItems) { _, newItems in
                guard !newItems.isEmpty else { return }
//                Task {
                Task {/* @MainActor in*/
                    let dtos = await viewModel.makeFramedDTOs(from: newItems)
                    
                    await MainActor.run {
                        FramedImageSelectList = dtos
                        if !dtos.isEmpty {
//                            navigateToImageSelectView = true
                            openImageSelect(with: dtos)
                        }
                        viewModel.selectedItems.removeAll()
                    }
                }
            }
            .task {
//                viewModel.loadSavedDrawing(diaryId: diaryLogId)
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

#Preview {
    PreviewWrapper()
}

private struct PreviewWrapper: View {
    @State private var vm = DiaryMainViewModel()
    @State private var showCanvas = false

    var body: some View {
        DiaryMainView(viewModel: vm, diaryLogId: 67, showCanvas: $showCanvas)
//        DiaryMainView(diaryLogId: 51)
    }
}
