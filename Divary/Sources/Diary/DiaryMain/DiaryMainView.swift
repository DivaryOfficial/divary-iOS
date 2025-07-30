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
    @State private var viewModel = DiaryMainViewModel()
    @FocusState private var isRichTextEditorFocused: Bool
    @State private var footerBarType: DiaryFooterBarType = .main
    
    @ViewBuilder
    private var activeFooterBar: some View {
        switch footerBarType {
        case .main:
            MainFooterBar(
                viewModel: viewModel,
                footerBarType: $footerBarType,
                isRichTextEditorFocused: $isRichTextEditorFocused
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
        VStack(spacing: 0) {
            diaryMain
            activeFooterBar
        }
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
                            
                        case .image(let image):
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .padding()
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .onChange(of: viewModel.selectedItems) { _, newItems in
                for item in newItems {
                    Task {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            await MainActor.run {
                                viewModel.addImage(uiImage)
                            }
                        }
                    }
                }
                viewModel.selectedItems.removeAll()
            }
        }
    }
}

#Preview {
    DiaryMainView()
}
