//
//  DiaryImageSelectView.swift
//  Divary
//
//  Created by 김나영 on 7/6/25.
//

import SwiftUI

struct DiaryImageSelectView: View {
//    @StateObject var viewModel: DiaryImageSelectViewModel //없어도되나
    @State private var showDeletePopup = false
    @State private var currentIndex = 0
    
    let decoViewModels: [DiaryImageDecoViewModel] = [
        DiaryImageDecoViewModel(frameType: .origin, isSelected: true),
        DiaryImageDecoViewModel(frameType: .pastelPink, isSelected: true),
        DiaryImageDecoViewModel(frameType: .black, isSelected: true)
    ]
    
    var body: some View {
        imageSlideGroup
        footerBar
    }
    
    private var imageSlideGroup: some View {
        VStack {
            ImageSlideView(framedImages: decoViewModels, currentIndex: $currentIndex)
            Spacer()
        }
    }
    
    private var footerBar: some View {
        HStack(spacing: 40) {
            Spacer()
            FooterItem(image: Image(.deco), title: "꾸미기")
            FooterItem(image: Image(.upload), title: "업로드")
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .overlay(
            Rectangle()
                .frame(height: 2)
                .foregroundColor(Color(.G_100)),
            alignment: .top
        )
    }
}

#Preview {
//    DiaryImageSelectView(viewModel: DiaryImageSelectViewModel())
    DiaryImageSelectView()
}
