//
//  CardGridView.swift
//  Divary
//
//  Created by 김나영 on 8/3/25.
//

import SwiftUI

struct CardGridView: View {
    let items: [SeaCreatureCard]
    @Binding var selectedCategory: SeaCreatureCategory
    
    var body: some View {
        CategoryTabBar(selectedCategory: $selectedCategory)
        ScrollView {
            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 14), count: 3), spacing: 26) {
                ForEach(items) { item in
                    CardComponent(
                        name: item.name,
                        type: item.type,
                        image: Image(item.nameImageAssetName)
                    )
                }
            }
        }
        .padding()
    }
}

#Preview {
    @Previewable @State var selectedCategory: SeaCreatureCategory = .all
    let mockItems = [
        SeaCreatureCard(id: 1, name: "흰동가리", type: "어류", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 2, name: "갯민숭달팽이", type: "연체동물류", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 3, name: "문어", type: "연체동물류", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 4, name: "흰동가리", type: "어류", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 5, name: "갯민숭달팽이", type: "연체동물류", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 6, name: "문어", type: "연체동물류", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 7, name: "흰동가리", type: "어류", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 8, name: "갯민숭달팽이", type: "연체동물류", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 9, name: "문어", type: "연체동물류", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 10, name: "흰동가리", type: "어류", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 11, name: "갯민숭달팽이", type: "연체동물류", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 12, name: "문어", type: "연체동물류", imageUrl: URL(string: "https://example.com")!)
    ]
    
    CardGridView(items: mockItems, selectedCategory: $selectedCategory)
}
