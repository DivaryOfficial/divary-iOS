//
//  DiaryImageSelectView.swift
//  Divary
//
//  Created by 김나영 on 7/6/25.
//

import SwiftUI

struct DiaryImageSelectView: View {
    @State private var showDeletePopup = false
    
    // 임시로 박아둔 이미지 셋
    private var imageSlideView = ImageSlideView(images: [
        UIImage(named: "tempImage")!,
        UIImage(named: "tempImage")!,
        UIImage(named: "tempImage")!
    ])
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Spacer()
                    .frame(height: 189)
                imageSlideView
                Spacer()
            }
            
            footerBar
            
            if showDeletePopup {
                DeletePopupView(
                    onCancel: {
                        showDeletePopup = false
                    },
                    onDelete: {
                        showDeletePopup = false
                    }
                )
            }
        }
    }
    
    private var footerBar: some View {
        HStack(spacing: 40) {
            Spacer()
            FooterItem(image: Image(.trash), title: "삭제")
                .onTapGesture {
                    showDeletePopup = true
                }
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
    DiaryImageSelectView()
}
