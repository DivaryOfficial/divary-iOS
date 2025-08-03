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
    let image: Image
    
    @State private var isSelected: Bool = false
    
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
                image
                    .resizable()
                    .scaledToFit()
            }
            .aspectRatio(1, contentMode: .fit)
            .padding(.bottom, 10)
            .onTapGesture {
                isSelected.toggle()
            }
            
            Text(name)
                .font(.omyu.regular(size: 18))
            Text(type)
                .font(.NanumSquareNeo.NanumSquareNeoRegular(size: 10))
                .foregroundStyle(Color(.grayscaleG600))
        }
    }
}

#Preview {
    CardComponent(name: "흰동가리", type: "어류", image: Image(.clownfish))
}
