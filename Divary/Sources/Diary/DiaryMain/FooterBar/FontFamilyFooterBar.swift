//
//  FontFamilyFooterBar.swift
//  Divary
//
//  Created by 바견규 on 7/29/25.
//

import SwiftUI

struct FontFamilyFooterBar: View {
    @Bindable var viewModel: DiaryMainViewModel
    @Binding var footerBarType: DiaryFooterBarType
    
    var body: some View {
        ZStack {
            // 상단 헤더
            HStack {
                Button(action: { footerBarType = .textStyle }) {
                    Image(.chevronLeft)
                        .foregroundStyle(Color(.bWBlack))
                }
                
                Spacer()
            }
            
            Text("글씨체")
                .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 18))
                .foregroundStyle(Color(.bWBlack))
            
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.G_100))
        
        // 글씨체 목록
        VStack(spacing: 0) {
            FontOptionRow(
                title: "기본 글씨체",
                font: Font.NanumSquareNeo.NanumSquareNeoBold(size: 16),
                fontName: "NanumSquareNeoTTF-cBd",
                isSelected: viewModel.getCurrentFontName() == "NanumSquareNeoTTF-cBd",
                action: { viewModel.setFontFamily("NanumSquareNeoTTF-cBd") }
            )
            
            FontOptionRow(
                title: "옴뮤 예쁜체",
                font: Font.omyu.regular(size: 16),
                fontName: "omyu_pretty",
                isSelected: viewModel.getCurrentFontName() == "omyu_pretty",
                action: { viewModel.setFontFamily("omyu_pretty") }
            )
            
            FontOptionRow(
                title: "온글잎 김콩해",
                font: Font.OwnglyphKonghae.konghaeRegular(size: 16),
                fontName: "Ownglyph_konghae-Rg",
                isSelected: viewModel.getCurrentFontName() == "Ownglyph_konghae-Rg",
                action: { viewModel.setFontFamily("Ownglyph_konghae-Rg") }
            )
            
            FontOptionRow(
                title: "카페24 고운밤",
                font: Font.Cafe24Oneprettynight.Cafe24OneprettynightRegular(size: 16),
                fontName: "Cafe24Oneprettynight",
                isSelected: viewModel.getCurrentFontName() == "Cafe24Oneprettynight",
                action: { viewModel.setFontFamily("Cafe24Oneprettynight") }
            )
            
            FontOptionRow(
                title: "나눔 한윤체",
                font: Font.NanumHanYunCe.NanumHanYunCeRegular(size: 16),
                fontName: "NanumHanYunCe",
                isSelected: viewModel.getCurrentFontName() == "NanumHanYunCe",
                action: { viewModel.setFontFamily("NanumHanYunCe") }
            )
        }
        .background(Color(.G_100))
    }
}
