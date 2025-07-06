//
//  ImageSlideView.swift
//  Divary
//
//  Created by 김나영 on 7/7/25.
//

import SwiftUI

struct ImageSlideView: View {
    let images: [UIImage]
    @State private var currentIndex = 0

    var body: some View {
        VStack {
            // 인덱스 표시
            Text("\(currentIndex + 1) / \(images.count)")
                .font(.headline)
                .padding(.top, 16)
            
            TabView(selection: $currentIndex) {
                ForEach(images.indices, id: \.self) { index in
                    Image(uiImage: images[index])
                        .resizable()
                        .scaledToFit()
                        .padding(.horizontal, 23)
                        .cornerRadius(8)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 280)
        }
    }
}

#Preview {
    ImageSlideView(images: [
        UIImage(named: "tempImage")!,
        UIImage(named:"photo")!,
        UIImage(named: "sticker")!
    ])
}
