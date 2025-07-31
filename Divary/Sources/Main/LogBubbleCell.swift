//
//  LogBubbleCell.swift
//  Divary
//
//  Created by 김나영 on 8/1/25.
//

import SwiftUI

struct LogBubbleCell: View {
    var iconType: IconType
    
    var body: some View {
        ZStack {
            Image(.bubble)
                .blur(radius: 3)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 1)
                )
            iconType.image
            
        }
    }
}

#Preview {
    LogBubbleCell(iconType: .clownfish)
}
