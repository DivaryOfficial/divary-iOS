//
//  DiaryImageFrame.swift
//  Divary
//
//  Created by 김나영 on 7/7/25.
//

import SwiftUI

struct DiaryImageFrame: View {
    @State private var imageCaption: String = ""
    @State private var imageDate: String = "임시 날짜 2025.5.25 7:32"

    var frameType: FrameType?
    var isSelected: Bool
    
    enum FrameType {
        case white
        case ivory
        case pastelPink
        case pastelBlue
        // case 종이질감
        case wood
        case black
        
        var frameColor: Color {
            switch self {
            case .white:
                return Color(.white)
            case .ivory:
                return Color(.ivory)
            case .pastelPink:
                return Color(.pastelPink)
            case .pastelBlue:
                return Color(.pastelBlue)
            case .wood:
                return Color(.wood)
            case .black:
                return Color(.black)
            }
        }
        
        var innerCornerRadius: CGFloat {
            switch self {
            case .white:
                return 1.6
            case .ivory:
                return 1.6
            case .pastelPink:
                return 1.6
            case .pastelBlue:
                return 8
            case .wood:
                return 1.6
            case .black:
                return 1.6
            }
        }
    }
    
    var body: some View {
        if let actualType = frameType {
            VStack {
                if isSelected {
                    Image("testImage")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(actualType.innerCornerRadius)
                        .padding(.top, 18)
                        .padding(.bottom, 16)
                
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("캡션 추가...", text: $imageCaption)
                            .foregroundColor(.black)
                        
                        Text(imageDate)
                            .foregroundColor(Color(.G_700))
                            .padding(.bottom, 18)
                    }
                }
                else {
                    Rectangle()
                        .fill(Color.white)
                        .cornerRadius(actualType.innerCornerRadius)
                        .padding(.top, 18)
                        .aspectRatio(1, contentMode: .fit)
                    Spacer()
                        .frame(height: 80)
                }
            }
            .padding(.horizontal, 18)
            .background(actualType.frameColor)
            .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
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
    DiaryImageFrame(frameType: .pastelBlue, isSelected: false)
//    DiaryImageFrame(type: nil)
}
