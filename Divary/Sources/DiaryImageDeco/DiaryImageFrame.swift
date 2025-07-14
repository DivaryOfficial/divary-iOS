//
//  DiaryImageFrame.swift
//  Divary
//
//  Created by 김나영 on 7/7/25.
//

import SwiftUI

struct DiaryImageFrame: View {
    @StateObject var viewModel: DiaryImageDecoViewModel
    
    let decoViewModels: [DiaryImageDecoViewModel] = [
        DiaryImageDecoViewModel(frameType: .white, isSelected: true),
        DiaryImageDecoViewModel(frameType: .pastelPink, isSelected: true),
        DiaryImageDecoViewModel(frameType: .black, isSelected: true)
    ]
    
    init(frameType: DiaryImageDecoViewModel.FrameType = .origin) {
        _viewModel = StateObject(wrappedValue: DiaryImageDecoViewModel(frameType: frameType, isSelected: false))
    }
    
    init(viewModel: DiaryImageDecoViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
//        switch viewModel.frameType {
//        case .origin:
//            
//        case default:
//            
//        }
//        let _ = print("DiaryImageFrameUpdated: \(viewModel.frameType)")
        if viewModel.frameType != .origin {
//            let _ = print("DiaryImageFrameUpdated: \(viewModel.frameType)")
            if viewModel.isSelected { // 꾸민 사진 띄우기
                VStack {
                    Image("testImage")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(viewModel.frameType.innerCornerRadius)
                        .padding(.top, 18)
                        .padding(.bottom, 16)
//                    ImageSlideView(content: .frames(decoViewModels))

                
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("캡션 추가...", text: $viewModel.imageCaption)
                            .foregroundColor(.black)
                        
                        Text(viewModel.imageDate)
                            .foregroundColor(Color(.G_700))
                            .padding(.bottom, 18)
                    }
                }
                .frame(width: 300)
                .padding(.horizontal, 18)
                .background(viewModel.frameType.frameColor)
                .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
            }
            else { // frameSelectBar에 띄우기
                VStack {
                    Rectangle()
                        .fill(Color.white)
                        .cornerRadius(viewModel.frameType.innerCornerRadius)
                        .aspectRatio(1, contentMode: .fit)
                    Spacer()
                        .frame(height: 20)
                }
                .frame(width: 60)
                .padding(.horizontal, 3)
                .padding(.top, 3)
                .background(viewModel.frameType.frameColor)
                .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
            }
        }
        else {
            if viewModel.isSelected {
                Image("testImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.top, 18)
                    .padding(.bottom, 16)
                    .padding(.horizontal, 48)
                    .cornerRadius(8)
            }
            else {
                ZStack {
                    Rectangle()
                        .frame(width: 70, height: 85) // 높이 수정 필요
                        .foregroundStyle(Color(.G_300))
                    Text("없음")
                        .foregroundStyle(Color(.black))
                }
            }
        }
    }
}

#Preview {
//    DiaryImageFrame(frameType: .pastelBlue, isSelected: true)
//    DiaryImageFrame(frameType: .origin, isSelected: false)
    DiaryImageFrame()
}
