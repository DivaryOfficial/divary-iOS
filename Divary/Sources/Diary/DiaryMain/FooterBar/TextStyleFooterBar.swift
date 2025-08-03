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
                viewModel.setUnderline(!viewModel.getCurrentIsUnderlined())
            }) {
                Image("humbleicons_underline")
                    .foregroundStyle(viewModel.getCurrentIsUnderlined() ?
                                     Color.primary_sea_blue : Color.bw_black)
            }
            
            Button(action: {
                viewModel.setStrikethrough(!viewModel.getCurrentIsStrikethrough())
            }) {
                Image("mi_strikethrough")
                    .foregroundStyle(viewModel.getCurrentIsStrikethrough() ?
                                     Color.primary_sea_blue : Color.bw_black)
            }
            
            Spacer()
        }
        .foregroundStyle(Color(.bWBlack))
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.G_100))
        .onChange(of: viewModel.forceUIUpdate) { _, _ in
            // UI 업데이트 트리거
        }
        .onChange(of: viewModel.richTextContext.attributedString) { _, _ in
            // 텍스트 변경 감지
        }
    }
}
