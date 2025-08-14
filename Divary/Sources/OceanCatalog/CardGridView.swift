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
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 14), count: 3), spacing: 26) {
                ForEach(items) { item in
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
                        imageURL: item.imageUrl,
                        isSelected: isSelected,
                        onTap: {
                            isSelected.wrappedValue.toggle()
                        }
                    )
                }
            }
        }
        .padding(.horizontal)
    }
}
