//
//  CustomPageIndicator.swift
//  Divary
//
//  Created by 바견규 on 7/9/25.
//

import SwiftUI

struct PageIndicatorView: View {
    let numberOfPages: Int
    let currentPage: Int
    var activeColor: Color = .blue
    var inactiveColor: Color = .gray.opacity(0.5)
    var circleSize: CGFloat = 10
    var spacing: CGFloat = 12

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? activeColor : inactiveColor)
                    .frame(width: circleSize, height: circleSize)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 20)
    }
}

