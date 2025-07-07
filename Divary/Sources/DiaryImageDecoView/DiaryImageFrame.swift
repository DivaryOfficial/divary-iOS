//
//  DiaryImageFrame.swift
//  Divary
//
//  Created by 김나영 on 7/7/25.
//

import SwiftUI

struct DiaryImageFrame: View {
    @StateObject var viewModel: DiaryImageDecoViewModel
    
    init(frameType: DiaryImageDecoViewModel.FrameType?, isSelected: Bool) {
        _viewModel = StateObject(wrappedValue: DiaryImageDecoViewModel(frameType: frameType, isSelected: isSelected))
    }
    
    var body: some View {
        if let actualType = viewModel.frameType {
            if viewModel.isSelected {
                VStack {
                    Image("testImage")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(actualType.innerCornerRadius)
                        .padding(.top, 18)
                        .padding(.bottom, 16)
                
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
                .background(actualType.frameColor)
                .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
            }
            else {
                VStack {
                    Rectangle()
                        .fill(Color.white)
                        .cornerRadius(actualType.innerCornerRadius)
                        .aspectRatio(1, contentMode: .fit)
                    Spacer()
                        .frame(height: 20)
                }
                .frame(width: 60)
                .padding(.horizontal, 3)
                .padding(.top, 3)
                .background(actualType.frameColor)
                .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
            }
        }
        else {
            Image("tempImage")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.top, 18)
                .padding(.bottom, 16)
                .cornerRadius(8)
        }
    }
}

#Preview {
//    DiaryImageFrame(frameType: .pastelBlue, isSelected: true)
    DiaryImageFrame(frameType: .pastelBlue, isSelected: false)
//    DiaryImageFrame(frameType: nil, isSelected: false)
}
