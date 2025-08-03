//
//  FontAlignmentFooterBar.swift
//  Divary
//
//  Created by 바견규 on 7/29/25.
//

import SwiftUI

struct FontAlignmentFooterBar: View {
    @Bindable var viewModel: DiaryMainViewModel
    @Binding var footerBarType: DiaryFooterBarType
    
    var body: some View {
        HStack(spacing: 20) {
            Button(action: { footerBarType = .main }) {
                Image(.iconamoonCloseThin)
            }
            
            alignmentButton(alignment: .left, image: .alignTextLeading)
            alignmentButton(alignment: .center, image: .alignTextCenter)
            alignmentButton(alignment: .right, image: .alignTextTrailing)
            
            Spacer()
        }
        .foregroundStyle(Color(.bWBlack))
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.G_100))
        .onChange(of: viewModel.currentTextAlignment) { _, _ in }
        .onChange(of: viewModel.forceUIUpdate) { _, _ in }
        .onChange(of: viewModel.richTextContext.attributedString) { _, _ in
            DispatchQueue.main.async {
                viewModel.currentTextAlignment = viewModel.getCurrentTextAlignment()
            }
        }
    }
    
    private func alignmentButton(alignment: NSTextAlignment, image: ImageResource) -> some View {
        Button(action: {
            viewModel.setTextAlignment(alignment)
        }) {
            Image(image)
                .foregroundStyle(viewModel.currentTextAlignment == alignment ?
                                Color.primary_sea_blue : Color.bw_black)
        }
        .background(
            viewModel.currentTextAlignment == alignment ?
            Color.blue.opacity(0.2) : Color.clear
        )
        .cornerRadius(6)
    }
}
