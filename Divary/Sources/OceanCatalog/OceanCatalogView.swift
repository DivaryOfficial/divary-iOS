//
//  OceanCatalogView.swift
//  Divary
//
//  Created by 김나영 on 8/4/25.
//

import SwiftUI

struct OceanCatalogView: View {
    @State private var selectedCategory: SeaCreatureCategory = .all
    
    private let allItems: [SeaCreatureCard] = [
        SeaCreatureCard(id: 1, name: "흰동가리", type: "어류", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 2, name: "갯민숭달팽이", type: "크크", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 3, name: "문어", type: "연체동물", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 4, name: "흰동가리", type: "어류", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 5, name: "갯민숭달팽이", type: "연체동물", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 6, name: "문어", type: "연체동물", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 7, name: "흰동가리", type: "어류", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 8, name: "갯민숭달팽이", type: "연체동물", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 9, name: "문어", type: "연체동물", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 10, name: "흰동가리", type: "어류", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 11, name: "갯민숭달팽이", type: "연체동물", imageUrl: URL(string: "https://example.com")!),
        SeaCreatureCard(id: 12, name: "문어", type: "연체동물", imageUrl: URL(string: "https://example.com")!)
    ]
    
    var filteredItems: [SeaCreatureCard] {
        switch selectedCategory {
        case .all:
            return allItems
        case .other:
            let excluded = ["어류", "갑각류", "연체동물"]
            return allItems.filter { !excluded.contains($0.type) }
        default:
            return allItems.filter { $0.type == selectedCategory.rawValue }
        }
}
    
    var body: some View {
        VStack {
            CategoryTabBar(selectedCategory: $selectedCategory)
            CardGridView(items: filteredItems)
        }
    }
}

#Preview {
    OceanCatalogView()
}
