//
//  ImageSelectView.swift
//  Divary
//
//  Created by 김나영 on 8/7/25.
//

import SwiftUI

struct ImageSelectView: View {
    @State var framedImages: [FramedImageDTO]
    
    @State private var showDeletePopup = false
    @State private var currentIndex = 0
    
    private var count: Int {
        framedImages.count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            imageSlideGroup
            footerBar
        }
        .overlay {
            if showDeletePopup {
                DeletePopupView(isPresented: $showDeletePopup, deleteText: "사진을 삭제할까요?")
            }
        }
    }
    
    private var imageSlideGroup: some View {
        VStack {
            // 인덱스 표시
            Text("\(currentIndex + 1) / \(count)")
                .font(.omyu.regular(size: 20))
                .padding(.top, 16)
            
            TabView(selection: $currentIndex) {
                ForEach(framedImages.indices, id: \.self) { index in
                    ZStack(alignment: .topTrailing) {
                        FramedImageComponent(framedImage: framedImages[index])
                            .padding(.horizontal, 23)
                            .tag(index)
                        
                        // delete 버튼 띄우기
                        Button(action: { showDeletePopup = true }) {
                            Image(.delete)
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                        .padding(.top, 25)
                        .padding(.trailing, 45)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
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
                .foregroundStyle(Color(.G_100)),
            alignment: .top
        )
    }
}

struct FooterItem: View {
    let image: Image
    let title: String

    var body: some View {
        VStack(spacing: 4) {
            image
                .frame(width: 40, height: 40)
                .padding(.bottom, 4)
            Text(title)
                .foregroundStyle(.black)
        }
    }
}

#Preview {
    let testImages = [
        FramedImageDTO(image: Image("testImage"), caption: "바다거북이와의 첫만남!", frameColor: .pastelBlue, date: "2025.08.07 7:32"),
        FramedImageDTO(image: Image("testImage"), caption: "바다거북이와의 첫만남!", frameColor: .pastelBlue, date: "2025.08.07 7:32")
    ]
    
    ImageSelectView(framedImages: testImages)
}
