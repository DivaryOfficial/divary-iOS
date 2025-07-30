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
            
            Button(action: {}) {
                Image(.sticker)
            }
            
            Button(action: {}) {
                Image(.pencil)
            }
            
            Spacer()
            
            if viewModel.editingTextBlock == nil {
                Button(action: {
                    viewModel.addTextBlock()
                    isRichTextEditorFocused.wrappedValue = true
                }) {
                    Image(.keyboard1)
                }
            } else {
                Button(action: {
                    viewModel.saveCurrentEditingBlock()
                    viewModel.commitEditingTextBlock()
                    isRichTextEditorFocused.wrappedValue = false
                    footerBarType = .main
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
