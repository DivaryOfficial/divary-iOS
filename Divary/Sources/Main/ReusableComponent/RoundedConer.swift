//
//  RoundedConer.swift
//  Divary
//
//  Created by 바견규 on 7/8/25.
//


//특정 코너만 둥글게할 수 있도록 만든 커스텀 Rect
import SwiftUI

extension View {
    func roundingCorner(_ radius : CGFloat, corners : UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner : Shape {
    var radius : CGFloat
    var corners : UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

