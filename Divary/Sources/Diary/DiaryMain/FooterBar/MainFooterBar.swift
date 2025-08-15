//
//  MainFooterBar.swift
//  Divary
//
//  Created by 바견규 on 7/29/25.
//

import SwiftUI
import PhotosUI

// MARK: - Main Footer Bar
struct MainFooterBar: View {
    @Bindable var viewModel: DiaryMainViewModel
    @Binding var footerBarType: DiaryFooterBarType
    var isRichTextEditorFocused: FocusState<Bool>.Binding
    
    @Binding var showCanvas: Bool
    
    var body: some View {
        HStack(spacing: 20) {
            PhotosPicker(selection: $viewModel.selectedItems, matching: .images) {
                Image(.photo)
            }
            
            Button(action: {
                // 텍스트 블록이 편집 중이 아닐 때만 스타일 바로 이동
                if viewModel.editingTextBlock != nil {
                    footerBarType = .textStyle
                }
            }) {
                Image(.font)
                    .foregroundStyle(viewModel.editingTextBlock != nil ?
                                   Color(.bWBlack) : Color(.bWBlack).opacity(0.5))
            }
            .disabled(viewModel.editingTextBlock == nil)
            
            Button(action: {
                // 텍스트 블록이 편집 중이 아닐 때만 정렬 바로 이동
                if viewModel.editingTextBlock != nil {
                    footerBarType = .alignment
                }
            }) {
                Image(.alignText)
                    .foregroundStyle(viewModel.editingTextBlock != nil ?
                                   Color(.bWBlack) : Color(.bWBlack).opacity(0.5))
            }
            .disabled(viewModel.editingTextBlock == nil)
            
            Button(action: { footerBarType = .sticker }) {
                Image(.sticker)
            }
            
            Button(action: { showCanvas = true }) {
                Image(.pencil)
            }
//            .disabled(isRichTextEditorFocused.wrappedValue)
            .disabled(viewModel.editingTextBlock != nil)
            
            Spacer()
            
            if viewModel.editingTextBlock == nil {
                Button(action: {
                    DispatchQueue.main.async {
                        // 1) 블록 추가(상태 변경)
                        viewModel.addTextBlock()
                        // 2) 포커스 전환은 다음 런루프로 미룸
                        DispatchQueue.main.async {
                            isRichTextEditorFocused.wrappedValue = true
    //                        footerBarType = .textStyle
                        }
                    }
                }) {
                    Image(.keyboard1)
                }
            } else {
                Button(action: {
                    // 1) 편집 저장(상태 변경)
                    viewModel.saveCurrentEditingBlock()
                    viewModel.commitEditingTextBlock()
                    // 2) 포커스/푸터바 전환은 다음 런루프로 미룸
                    DispatchQueue.main.async {
                        isRichTextEditorFocused.wrappedValue = false
                        footerBarType = .main
                    }
                }) {
                    Image(.keyboard)
                }
            }
        }
        .foregroundStyle(Color(.bWBlack))
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.G_100))
    }
}
