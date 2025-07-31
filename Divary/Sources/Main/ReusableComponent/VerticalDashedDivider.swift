//
//  VerticalDashedDivider.swift
//  Divary
//
//  Created by 바견규 on 7/9/25.
//

import SwiftUI

struct VerticalDashedDivider: View {
    var dashSize: CGSize = CGSize(width: 1, height: 4)
    var spacing: CGFloat = 3
    var color: Color = .gray

    var body: some View {
        Canvas { context, size in
            var y: CGFloat = 0
            while y < size.height {
                let rect = CGRect(x: (size.width - dashSize.width) / 2, y: y, width: dashSize.width, height: dashSize.height)
                context.fill(Path(rect), with: .color(color))
                y += dashSize.height + spacing
            }
        }
        .frame(width: dashSize.width)
    }
}
