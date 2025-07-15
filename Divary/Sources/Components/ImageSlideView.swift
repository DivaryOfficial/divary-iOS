//
//  ImageSlideView.swift
//  Divary
//
//  Created by 김나영 on 7/7/25.
//

import SwiftUI

struct ImageSlideView: View {
    enum SlideContent {
        case uiImages([UIImage])
        case frames([DiaryImageDecoViewModel])
    }
    let content: SlideContent
    
//    enum SlideContent {
//        case uiImages(UIImage)
//        case frames(DiaryImageDecoViewModel)
//    }
//    let content: [SlideContent]
    
    @Binding var currentIndex: Int

    var body: some View {
        VStack {
            // 인덱스 표시
            Text("\(currentIndex + 1) / \(count)")
                .font(.headline)
                .padding(.top, 16)
            
            TabView(selection: $currentIndex) {
                switch content {
                case .uiImages(let imageSet):
                    ForEach(imageSet.indices, id: \.self) { index in
                        Image(uiImage: imageSet[index])
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal, 23)
                            .cornerRadius(8)
                            .tag(index)
                    }
                    
                case .frames(let viewModels):
                    ForEach(viewModels.indices, id: \.self) { index in
                        DiaryImageFrame(viewModel: viewModels[index])
                            .padding(.horizontal, 23)
                            .tag(index)
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 280)
        }
    }
    
    private var count: Int {
        switch content {
        case .uiImages(let images): return images.count
        case .frames(let viewModels): return viewModels.count
        }
    }
}

//#Preview {
//    let decoViewModels: [DiaryImageDecoViewModel] = [
//        DiaryImageDecoViewModel(frameType: .white, isSelected: true),
//        DiaryImageDecoViewModel(frameType: .pastelPink, isSelected: true),
//        DiaryImageDecoViewModel(frameType: .pastelBlue, isSelected: true)
//    ]
//    
//    ImageSlideView(content: .frames(decoViewModels))
//}
