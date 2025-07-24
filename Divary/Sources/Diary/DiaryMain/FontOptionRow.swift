//
//  FontOptionRow.swift
//  Divary
//
//  Created by 바견규 on 7/23/25.
//

import SwiftUI

// 간단한 FontOptionRow
struct FontOptionRow: View {
    let title: String
    let font: Font
    let fontName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(font)
                .foregroundStyle(Color(.bWBlack))
            
            Spacer()
            
            if isSelected {
                ZStack {
                    Circle()
                        .fill(Color.primary_sea_blue)
                        .frame(width: 24, height: 24)
                    
                    Circle()
                        .fill(Color.grayscale_g100)
                        .frame(width: 18, height: 18) // 작은 흰색 원
                    
                    Circle()
                        .fill(Color.primary_sea_blue)
                        .frame(width: 10, height: 10) // 작은 흰색 원
                }
            } else {
                Image(systemName: "circle")
                    .foregroundStyle(Color.grayscale_g500)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
        .onTapGesture {
            action()
        }
    }
}

