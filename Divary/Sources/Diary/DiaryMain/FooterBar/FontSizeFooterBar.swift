//
//  FontSizeFooterBar.swift
//  Divary
//
//  Created by 바견규 on 7/29/25.
//

import SwiftUI

struct FontSizeFooterBar: View {
    @Bindable var viewModel: DiaryMainViewModel
    @Binding var footerBarType: DiaryFooterBarType
    
    private let fontSizes = [12, 14, 16, 18, 20, 24]
    @State private var selectedFontSize: CGFloat = 16
    
    var body: some View {
        HStack(spacing: 20) {
            Button(action: { footerBarType = .textStyle }) {
                Image(.iconamoonCloseThin)
            }
            
            ForEach(fontSizes, id: \.self) { size in
                Button(action: {
                    selectedFontSize = CGFloat(size)
                    viewModel.setFontSize(CGFloat(size))
                }) {
                    Text("\(size)")
                        .font(.system(size: 18))
                        .foregroundStyle(Int(selectedFontSize) == size ?
                                         Color.primary_sea_blue : Color.bw_black)
                }
            }
            
            Spacer()
        }
        .foregroundStyle(Color(.bWBlack))
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.G_100))
        .task {
            selectedFontSize = viewModel.getCurrentFontSize()
        }
        .onChange(of: viewModel.forceUIUpdate) { _, _ in
            selectedFontSize = viewModel.getCurrentFontSize()
        }
        .onChange(of: viewModel.richTextContext.attributedString) { _, _ in
            selectedFontSize = viewModel.getCurrentFontSize()
        }
    }
}
