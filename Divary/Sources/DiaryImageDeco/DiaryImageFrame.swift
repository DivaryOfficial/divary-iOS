//
//  DiaryImageFrame.swift
//  Divary
//
//  Created by 김나영 on 7/7/25.
//

import SwiftUI

struct DiaryImageFrame: View {
    @StateObject var viewModel: DiaryImageDecoViewModel

    init(frameType: DiaryImageDecoViewModel.FrameType = .origin) {
        _viewModel = StateObject(wrappedValue: DiaryImageDecoViewModel(frameType: frameType, isSelected: false))
    }
    
//    init(frameType: DiaryImageDecoViewModel.FrameType = .pastelBlue) {
//        _viewModel = StateObject(wrappedValue: DiaryImageDecoViewModel(frameType: frameType, isSelected: true))
//    }
    
    init(viewModel: DiaryImageDecoViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        if viewModel.frameType != .origin {
            if viewModel.isSelected { // 꾸민 사진 띄우기
                VStack {
                    Image("testImage")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 230, height: 230)
                        .clipped()
                        .cornerRadius(viewModel.frameType.innerCornerRadius)
                        .padding(.top, 15)
                        .padding(.bottom, 16)
                
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("캡션 추가...", text: $viewModel.imageCaption)
                            .foregroundColor(.black)
                        
                        Text(viewModel.imageDate)
                            .foregroundColor(Color(.G_700))
                            .padding(.bottom, 18)
                    }
                }
                .frame(width: 240)
                .padding(.horizontal, 10)
                .background(viewModel.frameType.frameColor)
                .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
            }
            else { // frameSelectBar에 프레임 버튼들
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
            if viewModel.isSelected { // frame 없이 원본 사진 띄우기
                Image("testImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(8)
            }
            else { // frameSelectBar에 없음 버튼
                ZStack {
                    Rectangle()
                        .frame(width: 70, height: 85)
                        .foregroundStyle(Color(.G_300))
                    Text("없음")
                        .foregroundStyle(Color(.black))
                }
            }
        }
    }
}

#Preview {
    DiaryImageFrame()
}
