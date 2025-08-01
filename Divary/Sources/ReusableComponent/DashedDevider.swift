//
//  DashedDevider.swift
//  Divary
//
//  Created by 바견규 on 7/9/25.
//

import SwiftUI


struct DashedDivider: View {
    var dashSize: CGSize
    var spacing: CGFloat
    var color: Color

    init(
        dashSize: CGSize = CGSize(width: 2, height: 1),
        spacing: CGFloat = 3,
        color: Color = Color.grayscale_g300
    ) {
        self.dashSize = dashSize
        self.spacing = spacing
        self.color = color
    }

    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let itemWidth = dashSize.width + spacing
            let count = Int(totalWidth / itemWidth)
            let adjustedSpacing = (totalWidth - CGFloat(count) * dashSize.width) / CGFloat(max(count - 1, 1))

            HStack(spacing: adjustedSpacing) {
                ForEach(0..<count, id: \.self) { _ in
                    Rectangle()
                        .fill(color)
                        .frame(width: dashSize.width, height: dashSize.height)
                }
            }
        }
        .frame(height: dashSize.height)
    }
}

