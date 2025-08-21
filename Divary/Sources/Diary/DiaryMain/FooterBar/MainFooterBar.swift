//  MainFooterBar.swift
//  Divary
//
//  키보드 상호작용 완전 버전

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
            .disabled(viewModel.editingTextBlock != nil)
            
            Button(action: {
                if viewModel.editingTextBlock != nil {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        footerBarType = .textStyle
                    }
                }
            }) {
                Image(.font)
                    .foregroundStyle(viewModel.editingTextBlock != nil ?
                                   Color(.bWBlack) : Color(.bWBlack).opacity(0.5))
            }
            .disabled(viewModel.editingTextBlock == nil)
            
            Button(action: {
                if viewModel.editingTextBlock != nil {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        footerBarType = .alignment
                    }
                }
            }) {
                Image(.alignText)
                    .foregroundStyle(viewModel.editingTextBlock != nil ?
                                   Color(.bWBlack) : Color(.bWBlack).opacity(0.5))
            }
            .disabled(viewModel.editingTextBlock == nil)
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    footerBarType = .sticker
                }
            }) {
                Image(.sticker)
            }
            .disabled(viewModel.editingTextBlock != nil)
            
            Button(action: {
                if viewModel.editingTextBlock != nil {
                    commitTextEditingAndShowCanvas()
                } else {
                    showCanvas = true
                }
            }) {
                Image(.pencil)
            }
            
            Spacer()
            
            if viewModel.editingTextBlock == nil {
                Button(action: {
                    viewModel.addTextBlock()
                }) {
                    Image(.keyboard1)
                }
                .transition(.scale.combined(with: .opacity))
            } else {
                Button(action: {
                    commitTextEditing()
                }) {
                    Image(.keyboard)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .foregroundStyle(Color(.bWBlack))
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Color(.G_100)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: -1)
        )
        .animation(.easeInOut(duration: 0.3), value: viewModel.editingTextBlock != nil)
    }
    
    // MARK: - 텍스트 편집 완료 처리
    
    private func commitTextEditing() {
        viewModel.saveCurrentEditingBlock()
        viewModel.commitEditingTextBlock()
        
        withAnimation(.easeOut(duration: 0.25)) {
            isRichTextEditorFocused.wrappedValue = false
            footerBarType = .main
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            viewModel.recomputeCanSave()
        }
    }
    
    private func commitTextEditingAndShowCanvas() {
        commitTextEditing()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            showCanvas = true
        }
    }
}
