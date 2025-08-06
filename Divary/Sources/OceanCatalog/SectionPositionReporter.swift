//
//  SectionPositionReporter.swift
//  Divary
//
//  Created by 김나영 on 8/6/25.
//

import Foundation
import SwiftUI

struct SectionPositionReporter: View {
    let section: SectionType

    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: SectionPositionKey.self, value: [SectionAnchor(section: section, minY: geometry.frame(in: .named("scroll")).minY)])
        }
    }
}

struct SectionAnchor: Equatable {
    let section: SectionType
    let minY: CGFloat
}

struct SectionPositionKey: PreferenceKey {
    static var defaultValue: [SectionAnchor] = []
    
    static func reduce(value: inout [SectionAnchor], nextValue: () -> [SectionAnchor]) {
        value.append(contentsOf: nextValue())
    }
}
