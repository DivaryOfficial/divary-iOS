//
//  ImageSlideView.swift
//  Divary
//
//  Created by 김나영 on 7/7/25.
//

import SwiftUI

struct ImageSlideView: View {
//    @StateObject var viewModel: DiaryImageSelectViewModel = DiaryImageSelectViewModel()
    @State private var showDeletePopup = false
    
    var framedImages: [DiaryImageDecoViewModel]
    var isSelectView: Bool = true
    
    @Binding var currentIndex: Int
    
    private var count: Int {
        framedImages.count
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            imageSlide
            
            if showDeletePopup {
                DeletePopupView(isPresented: $showDeletePopup, deleteText: "사진을 삭제할까요?")
            }
        }
    }
    
    private var imageSlide: some View {
        VStack {
            // 인덱스 표시
            Text("\(currentIndex + 1) / \(count)")
                .font(.omyu.regular(size: 20))
                .padding(.top, 16)
            
            TabView(selection: $currentIndex) {
                ForEach(framedImages.indices, id: \.self) { index in
                    ZStack(alignment: .topTrailing) {
                        DiaryImageFrame(viewModel: framedImages[index])
                            .padding(.horizontal, 23)
                            .tag(index)
                        
                        if isSelectView { // delete 버튼 띄우기
                            Button(action: { showDeletePopup = true }) {
                                Image(.delete)
                                    .resizable()
                                    .frame(width: 30, height: 30)
                            }
                            .padding(.top, 25)
                            .padding(.trailing, 45)
                        }
                    }
                    .frame(maxWidth: .infinity)
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
                DiaryImageDecoViewModel(frameType: .pastelPink, isSelected: true),
                DiaryImageDecoViewModel(frameType: .origin, isSelected: true),
                DiaryImageDecoViewModel(frameType: .pastelBlue, isSelected: true)
            ]
            
            ImageSlideView(framedImages: decoViewModels, currentIndex: $index)
        }
    }

    return PreviewWrapper()
}
