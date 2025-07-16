//
//  ImageSlideView.swift
//  Divary
//
//  Created by 김나영 on 7/7/25.
//

import SwiftUI

struct ImageSlideView: View {
    var framedImages: [DiaryImageDecoViewModel]
    
    @Binding var currentIndex: Int
    
    private var count: Int {
        framedImages.count
    }

    var body: some View {
        VStack {
            // 인덱스 표시
            Text("\(currentIndex + 1) / \(count)")
                .font(.headline)
                .padding(.top, 16)
            TabView(selection: $currentIndex) {
                ForEach(framedImages.indices, id: \.self) { index in
                    DiaryImageFrame(viewModel: framedImages[index])
                        .padding(.horizontal, 23)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            Spacer()
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var index = 0
        
        var body: some View {
            let decoViewModels: [DiaryImageDecoViewModel] = [
                DiaryImageDecoViewModel(frameType: .origin, isSelected: true),
                DiaryImageDecoViewModel(frameType: .pastelPink, isSelected: true),
                DiaryImageDecoViewModel(frameType: .pastelBlue, isSelected: true)
            ]
            
            ImageSlideView(framedImages: decoViewModels, currentIndex: $index)
        }
    }

    return PreviewWrapper()
}
