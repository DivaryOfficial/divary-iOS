//
//  FramedImageComponent.swift
//  Divary
//
//  Created by 김나영 on 8/7/25.
//

import Foundation
import SwiftUI

struct FramedImageComponent: View {
    @ObservedObject var framedImage: FramedImageDTO
    var isEditing: Bool = false
    
    var body: some View {
        if framedImage.frameColor == .origin {
            framedImage.image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(8)
        }
        else {
            ZStack {
                Rectangle()
                    .fill(framedImage.frameColor.frameColor)
                    .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
                VStack {
                    framedImage.image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 230, height: 230)
                        .clipped()
                        .cornerRadius(8)
                        .padding(.top, 15)
                        .padding(.bottom, 16)
                    
                    VStack(alignment: .leading, spacing: 7) {
                        if isEditing {
                            TextField("캡션 추가...", text: $framedImage.caption)
                                .font(.omyu.regular(size: 20))
                                .foregroundStyle(.black)
                        } else {
                            Text(framedImage.caption)
                                .font(.omyu.regular(size: 20))
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Text(framedImage.date)
                            .font(.NanumSquareNeo.NanumSquareNeoBold(size: 12))
                            .foregroundStyle(Color(.G_700))
                            .padding(.bottom, 18)
                    }
                }
                .padding(.horizontal, 10)
            }
            .frame(width: 260, height: 230)
            .frame(maxWidth: 260, maxHeight: 340)
        }
    }
}

#Preview {
    let testImage = FramedImageDTO(image: Image("testImage"), caption: "바다거북이와의 첫만남!", frameColor: .pastelBlue, date: "2025.08.07 7:32")
    
    return FramedImageComponent(framedImage: testImage)
}

