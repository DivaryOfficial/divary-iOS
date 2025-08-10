//
//  CardComponent.swift
//  Divary
//
//  Created by 김나영 on 8/3/25.
//

import SwiftUI

struct CardComponent: View {
    let name: String
    let type: String
//    let image: Image
    let imageURL: URL?
    @Binding var isSelected: Bool
    let onTap: () -> Void
    
//    @State private var isSelected: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                Rectangle()
                    .fill(isSelected ? Color.white : Color(.grayscaleG100))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.seaBlue), lineWidth: isSelected ? 1 : 0)
                    )
                if let url = imageURL {
//                    let _ = print("🔗 Image URL:", url.absoluteString)
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img):
                            img
                                .resizable()
                                .scaledToFit()
                        case .empty:
                            // 로딩 상태
                            ProgressView()
                        case .failure:
                            // 실패 시 플레이스홀더
                            Image("placeholder")
                                .resizable()
                                .scaledToFit()
                        @unknown default:
                            Image("placeholder")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                } else {
                    // URL 없으면 플레이스홀더
                    Image("placeholder")
                        .resizable()
                        .scaledToFit()
                }
//                image
//                    .resizable()
//                    .scaledToFit()
            }
            .aspectRatio(1, contentMode: .fit)
            .padding(.bottom, 10)
            .onTapGesture {
//                isSelected.toggle()
                onTap()
            }
            
            Text(name)
                .font(.omyu.regular(size: 18))
            Text(type)
                .font(.NanumSquareNeo.NanumSquareNeoRegular(size: 10))
                .foregroundStyle(Color(.grayscaleG600))
        }
    }
}

//#Preview {
//    CardComponent(name: "흰동가리", type: "어류", image: Image(.clownfish))
//}
