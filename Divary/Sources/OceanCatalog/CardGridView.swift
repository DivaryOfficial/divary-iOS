//
//  CardGridView.swift
//  Divary
//
//  Created by 김나영 on 8/3/25.
//

import SwiftUI

struct CardGridView: View {
    let items: [SeaCreatureCard]
    @Binding var selectedCard: SeaCreatureCard?
    let onSelect: (SeaCreatureCard) -> Void
    
    @State private var viewModel: OceanCatalogViewModel = .init()
    
    var body: some View {
        
        let _ = viewModel.getCardList(type: "어류")
        ScrollView {
            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 14), count: 3), spacing: 26) {
                ForEach(viewModel.creatureCards.map({
                    SeaCreatureCard(id: $0.id, name: $0.name, type: $0.type, imageUrl: $0.dogamProfileUrl!)
                })) { item in
//                    CardComponent(
//                        name: item.name,
//                        type: item.type,
//                        image: Image(item.nameImageAssetName)
//                    )
                    let isSelected = Binding<Bool>(
                        get: { selectedCard?.id == item.id },
                        set: { newValue in
                            if newValue {
                                selectedCard = item
                                onSelect(item)
                            } else {
                                selectedCard = nil
                            }
                        }
                    )
                    CardComponent(
                        name: item.name,
                        type: item.type,
                        image: Image(item.nameImageAssetName),
                        isSelected: isSelected,
                        onTap: {
                            isSelected.wrappedValue.toggle()
                        }
                    )
                }
            }
        }
        .padding()
    }
}

//#Preview {
//    let mockItems = [
//        SeaCreatureCard(id: 1, name: "흰동가리", type: "어류", imageUrl: URL(string: "https://example.com")!),
//        SeaCreatureCard(id: 2, name: "갯민숭달팽이", type: "연체동물류", imageUrl: URL(string: "https://example.com")!),
//        SeaCreatureCard(id: 3, name: "문어", type: "연체동물류", imageUrl: URL(string: "https://example.com")!),
//        SeaCreatureCard(id: 4, name: "흰동가리", type: "어류", imageUrl: URL(string: "https://example.com")!),
//        SeaCreatureCard(id: 5, name: "갯민숭달팽이", type: "연체동물류", imageUrl: URL(string: "https://example.com")!),
//        SeaCreatureCard(id: 6, name: "문어", type: "연체동물류", imageUrl: URL(string: "https://example.com")!),
//        SeaCreatureCard(id: 7, name: "흰동가리", type: "어류", imageUrl: URL(string: "https://example.com")!),
//        SeaCreatureCard(id: 8, name: "갯민숭달팽이", type: "연체동물류", imageUrl: URL(string: "https://example.com")!),
//        SeaCreatureCard(id: 9, name: "문어", type: "연체동물류", imageUrl: URL(string: "https://example.com")!),
//        SeaCreatureCard(id: 10, name: "흰동가리", type: "어류", imageUrl: URL(string: "https://example.com")!),
//        SeaCreatureCard(id: 11, name: "갯민숭달팽이", type: "연체동물류", imageUrl: URL(string: "https://example.com")!),
//        SeaCreatureCard(id: 12, name: "문어", type: "연체동물류", imageUrl: URL(string: "https://example.com")!)
//    ]
//    
//    CardGridView(items: mockItems)
//}
