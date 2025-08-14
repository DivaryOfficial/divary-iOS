//
//  ImageSelectView.swift
//  Divary
//
//  Created by 김나영 on 8/7/25.
//

import SwiftUI

struct ImageSelectView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var viewModel: DiaryMainViewModel
    @State var framedImages: [FramedImageContent]
    
    @State private var showDeletePopup = false
    @State private var currentIndex = 0
    
    @State private var showImageDecoView = false
    
    var onComplete: (([FramedImageContent]) -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            imageSlideGroup
            footerBar
        }
        .navigationDestination(isPresented: $showImageDecoView) {
            ImageDecoView(framedImages: framedImages,
                currentIndex: $currentIndex,
                onApply: { edited in
                    self.framedImages = edited
                }
            )
        }
        .overlay {
            if showDeletePopup {
                DeletePopupView(
                    isPresented: $showDeletePopup,
                    deleteText: "사진을 삭제할까요?",
                    onDelete: {
                        withAnimation {
                            guard !framedImages.isEmpty,
                                  framedImages.indices.contains(currentIndex) else {
                                showDeletePopup = false
                                return
                            }
                            framedImages.remove(at: currentIndex)
                            
                            if framedImages.isEmpty {
                                showDeletePopup = false
                                if let onComplete = onComplete {
                                    onComplete([]) // 메인뷰에 삭제 신호 보내기
                                }
                                dismiss()
                                
                                return
                            }
                            
                            if currentIndex >= framedImages.count {
                                currentIndex = max(0, framedImages.count - 1)
                            }
                            showDeletePopup = false
                        }
                    }
                )
            }
        }
//        .onAppear {
        .task {
            for (i, f) in framedImages.enumerated() {
                print("[\(i)] hasLocal=\(f.originalData != nil) temp=\(f.tempFilename ?? "nil") imageNil=\(f.image == nil)")
            }
        }

    }
    
    private var imageSlideGroup: some View {
        VStack {
            ZStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(.chevronLeft)
                            .foregroundStyle(.black)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                
                // 인덱스 중앙
                Text("\(currentIndex + 1) / \(framedImages.count)")
                    .font(.omyu.regular(size: 20))
            }
            
            TabView(selection: $currentIndex) {
                ForEach(framedImages.indices, id: \.self) { index in
                    ZStack(alignment: .top/*Trailing*/) {
                        FramedImageComponentView(framedImage: framedImages[index])
//                            .padding(.horizontal, 23)
                            .tag(index)
                        
                        // delete 버튼 띄우기
                        Button(action: { showDeletePopup = true }) {
                            Image(.delete)
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding(.top, 35)
                                .padding(.leading, 260)
                        }
                        
                    }
//                    .frame(maxWidth: .infinity)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            Spacer()
        }
    }
    
    
    private var footerBar: some View {
        HStack(spacing: 40) {
            Spacer()
            
            Button(action: {
                showImageDecoView = true
            }) {
                FooterItem(image: Image(.deco), title: "꾸미기")
            }
            
            Button(action: {
//                viewModel.addImages(framedImages)
                if let onComplete = onComplete {
                    onComplete(framedImages)   // ✅ 콜백 실행
                } else {
                    viewModel.addImages(framedImages) // 기존 로직
                }
                dismiss()
            }) {
                FooterItem(image: Image(.upload), title: "업로드")
            }
            
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
    @Bindable var viewModel = DiaryMainViewModel()
    let testImages = [
        FramedImageContent(image: Image("testImage"), caption: "바다거북이와의 첫만남!", frameColor: .origin, date: "2025.08.07 7:32"),
        FramedImageContent(image: Image("testImage"), caption: "바다거북이와의 첫만남!", frameColor: .pastelBlue, date: "2025.08.07 7:32")
    ]
    
    ImageSelectView(viewModel: viewModel, framedImages: testImages)
}
