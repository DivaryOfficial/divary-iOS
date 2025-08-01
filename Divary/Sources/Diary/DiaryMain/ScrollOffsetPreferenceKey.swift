//
//  ScrollOffsetPreferenceKey.swift
//  Divary
//
//  Created by 김나영 on 7/25/25.
//

import Foundation
import SwiftUICore

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
