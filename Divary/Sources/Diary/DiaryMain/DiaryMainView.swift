//  DiaryMainView.swift
//  Divary
//
//  Created by 김나영 on 7/6/25.

import SwiftUI
import PhotosUI
import RichTextKit

enum DiaryFooterBarType {
    case main, textStyle, fontSize, alignment, fontFamily
}

struct DiaryMainView: View {
    let diaryId: Int
    
    @State private var viewModel = DiaryMainViewModel()
    @FocusState private var isRichTextEditorFocused: Bool
    @State private var footerBarType: DiaryFooterBarType = .main
    
    @State private var navigateToImageSelectView = false
    @State private var FramedImageSelectList: [FramedImageDTO] = []
    
    @State var showCanvas: Bool = false
    @State private var currentOffsetY: CGFloat = 0
    
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
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                diaryMain
                activeFooterBar
            }
        }
        .fullScreenCover(isPresented: $navigateToImageSelectView) {
            NavigationStack {
                let _ = print(FramedImageSelectList.count)
                ImageSelectView(viewModel: viewModel, framedImages: FramedImageSelectList)
                    .background(Color.white)
            }
        }
        .overlay(
            showCanvas ? DiaryCanvasView(
                viewModel: DiaryCanvasViewModel(showCanvas: $showCanvas, diaryId: 0),
                offsetY: currentOffsetY,
                onSaved: { drawing, offset in
                    viewModel.savedDrawing = drawing
                    viewModel.drawingOffsetY = offset
                }
            ) : nil
        )
    }
    
    private var diaryMain: some View {
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
                                    content: content
                                )
                            } else {
                                CustomAttributedTextView(attributedText: content.text)
                                    .fixedSize(horizontal: false, vertical: true)
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
                           
                        case .image(let dto):
                            FramedImageComponent(framedImage: dto)
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height)
                
                if !showCanvas, let drawing = viewModel.savedDrawing {
                    DrawingScreenView(drawing: drawing)
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .named("scroll")).origin.y)
                    }
                }
            }
            // 기존
            .onChange(of: viewModel.selectedItems) { _, newItems in
                guard !newItems.isEmpty else { return }
                Task {
                    let dtos = await viewModel.makeFramedDTOs(from: newItems)
                    
                    await MainActor.run {
                        FramedImageSelectList = dtos
                        if !dtos.isEmpty {
                            navigateToImageSelectView = true
                        }
                        viewModel.selectedItems.removeAll()
                    }
                }
            }
            .task {
                viewModel.loadSavedDrawing(diaryId: diaryId)
            }
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            currentOffsetY = -value
        }
    }
}

#Preview {
    PreviewWrapper()
}

private struct PreviewWrapper: View {
    @State private var showCanvas = false

    var body: some View {
        DiaryMainView(diaryId: 0)
    }
}
