//
//  TextStyleFooterBar.swift
//  Divary
//
//  Created by 바견규 on 7/29/25.
//

import SwiftUI

struct TextStyleFooterBar: View {
    @Bindable var viewModel: DiaryMainViewModel
    @Binding var footerBarType: DiaryFooterBarType
    
    var body: some View {
        HStack(spacing: 20) {
            Button(action: { footerBarType = .main }) {
                Image(.iconamoonCloseThin)
            }
            
            Button(action: { footerBarType = .fontFamily }) {
                Image("mingcute_font-size-line")
            }
            
            Button(action: { footerBarType = .fontSize }) {
                Text("\(Int(viewModel.getCurrentFontSize()))")
                    .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 18))
            }
            
            Button(action: {
                viewModel.toggleStyle(.underlined)
            }) {
                Image("humbleicons_underline")
                    .foregroundStyle(viewModel.richTextContext.hasStyle(.underlined) ?
                                     Color.primary_sea_blue : Color.bw_black)
            }
            
            Button(action: {
                viewModel.toggleStyle(.strikethrough)
            }) {
                Image("mi_strikethrough")
                    .foregroundStyle(viewModel.richTextContext.hasStyle(.strikethrough) ?
                                     Color.primary_sea_blue : Color.bw_black)
            }
            
            Spacer()
        }
        .foregroundStyle(Color(.bWBlack))
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.G_100))
        .onChange(of: viewModel.forceUIUpdate) { _, _ in }
        .onChange(of: viewModel.richTextContext.attributedString) { _, _ in }
    }
}
