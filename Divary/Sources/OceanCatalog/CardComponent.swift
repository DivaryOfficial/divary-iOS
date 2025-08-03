//
//  CardComponent.swift
//  Divary
//
//  Created by 김나영 on 8/3/25.
//

import SwiftUI

struct CardComponent: View {
    @State private var isSelected: Bool = false
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(isSelected ? Color.white : Color(.grayscaleG100))
                .frame(width: 100, height: 100)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.seaBlue), lineWidth: isSelected ? 1 : 0)
                )
            Image(.clownfish)
        }
        .onTapGesture {
            isSelected.toggle()
        }
    }
}

#Preview {
    CardComponent()
}
