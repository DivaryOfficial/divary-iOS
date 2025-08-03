//
//  CardGridView.swift
//  Divary
//
//  Created by 김나영 on 8/3/25.
//

import SwiftUI

struct CardGridView: View {
    let items: [SeaCreatureCard]
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 14), count: 3), spacing: 26) {
            ForEach(items) { item in
                CardComponent(
                    name: item.name,
                    type: item.type,
                    image: Image(item.nameImageAssetName)
                )
            }
        }
        .padding()
    }
}

#Preview {
    let mockItems = [
        SeaCreatureCard(id: 1, name: "흰동가리", type: "어류", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 2, name: "갯민숭달팽이", type: "연체동물", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 3, name: "문어", type: "연체동물", imageUrl: URL(string: "https://example.com")!)
    ]
    
    CardGridView(items: mockItems)
}
