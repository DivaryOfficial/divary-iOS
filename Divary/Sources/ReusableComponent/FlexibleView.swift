//
//  Flow.swift
//  Divary
//
//  Created by chohaeun on 7/18/25.
//

import SwiftUI

// PreferenceKey는 generic 밖으로!
struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
struct FlexibleView<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content

    init(data: Data,
         spacing: CGFloat = 8,
         alignment: HorizontalAlignment = .leading,
         @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }

    @State private var totalHeight: CGFloat = .zero

    var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            generateContent()
        }
        .frame(height: totalHeight)
    }

    private func generateContent() -> some View {
        var width: CGFloat = 0
        var height: CGFloat = 0

        return GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                ForEach(data, id: \.self) { item in
                    content(item)
                        .alignmentGuide(.leading, computeValue: { d in
                            if width + d.width > geo.size.width {
                                width = 0
                                height += d.height + spacing
                            }
                            let result = width
                            width += d.width + spacing
                            return result
                        })
                        .alignmentGuide(.top, computeValue: { _ in height })
                }
            }
            .background(viewHeightReader())
        }
    }

    private func viewHeightReader() -> some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: HeightPreferenceKey.self,
                            value: geometry.size.height)
        }
        .onPreferenceChange(HeightPreferenceKey.self) { self.totalHeight = $0 }
    }

    struct HeightPreferenceKey: PreferenceKey {
        static var defaultValue: CGFloat { 0 }

        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
}
