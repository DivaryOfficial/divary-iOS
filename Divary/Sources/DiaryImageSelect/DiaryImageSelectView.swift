//
//  DiaryImageSelectView.swift
//  Divary
//
//  Created by 김나영 on 7/6/25.
//

import SwiftUI

struct DiaryImageSelectView: View {
    @StateObject var viewModel: DiaryImageSelectViewModel
    @State private var currentIndex = 0
    
    let decoViewModels: [DiaryImageDecoViewModel] = [
        DiaryImageDecoViewModel(frameType: .origin, isSelected: true),
        DiaryImageDecoViewModel(frameType: .pastelPink, isSelected: true),
        DiaryImageDecoViewModel(frameType: .black, isSelected: true)
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            imageSlideGroup
            footerBar
            
            if viewModel.showDeletePopup {
                DeletePopupView(deleteText: "사진을 삭제할까요?")
            }
        }
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
    DiaryImageSelectView(viewModel: DiaryImageSelectViewModel())
}
