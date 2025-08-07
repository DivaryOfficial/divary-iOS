//
//  ImageDecoView.swift
//  Divary
//
//  Created by 김나영 on 8/7/25.
//

import SwiftUI

struct ImageDecoView: View {
    @State var framedImages: [FramedImageDTO]
    @State var selectedFrame: FrameColor = .origin
    
    @State private var showDeletePopup = false
    @Binding var currentIndex: Int
    
    private var count: Int {
        framedImages.count
    }
    
    var body: some View {
        VStack {
            headerBar
            Spacer()
            imageDecoSlideGroup
            Spacer()
            FrameSelectBar(selectedFrame: $selectedFrame)
        }
        .overlay {
            if showDeletePopup {
                DeletePopupView(isPresented: $showDeletePopup, deleteText: "지금 돌아가면 변경 내용이 모두 삭제됩니다.")
            }
        }
        .onChange(of: selectedFrame) {
            if framedImages.indices.contains(currentIndex) {
                framedImages[currentIndex].frameColor = selectedFrame
            }
        }
    }
    
    private var headerBar: some View {
        HStack {
            Button(action: { showDeletePopup = true }) {
                Image(.close)
            }
            Spacer()
            
            Text("\(currentIndex + 1) / \(count)")
                .font(.omyu.regular(size: 20))
            
            Spacer()
            Button(action: { }) {
                Image(.check)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var imageDecoSlideGroup: some View {
        TabView(selection: $currentIndex) {
            ForEach(framedImages.indices, id: \.self) { index in
                FramedImageComponent(framedImage: framedImages[index], isEditing: true)
                    .padding(.horizontal, 23)
                    .tag(index)
                    .frame(maxWidth: .infinity)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
}

#Preview {
    @Previewable @State var index = 0
    
    let testImages = [
        FramedImageDTO(image: Image("testImage"), caption: "바다거북이와의 첫만남!", frameColor: .pastelBlue, date: "2025.08.07 7:32"),
        FramedImageDTO(image: Image("testImage"), caption: "바다거북이와의 첫만남!", frameColor: .pastelBlue, date: "2025.08.07 7:32")
    ]
    
    ImageDecoView(framedImages: testImages, currentIndex: $index)
}
