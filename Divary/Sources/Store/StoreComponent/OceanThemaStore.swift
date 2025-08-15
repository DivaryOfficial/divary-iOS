//
//  OceanThemaStore.swift
//  Divary
//
//  Created by 바견규 on 8/13/25.
//

import SwiftUI

struct StoreItem: Identifiable {
    let id = UUID()
    let image: String
    let text: String
    let type: BackgroundType
}

struct OceanThemeStore: View {
    @Bindable var viewModel: CharacterViewModel
    
    private let items: [StoreItem] = [
        StoreItem(image: "CoralForestStore", text: "산호숲", type: .coralForest),
        StoreItem(image: "EmeraldStore", text: "에메랄드", type: .emerald),
        StoreItem(image: "PinkLakeStore", text: "핑크호수", type: .pinkLake),
        StoreItem(image: "ShipWreckStore", text: "난파선", type: .deepSea)
    ]
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            Spacer().frame(height: 20)
            LazyVGrid(columns: columns, spacing: 30) {
                ForEach(items) { item in
                    OceanThemaStoreComponent(
                        imgText: item.image,
                        componentText: item.text,
                        isSelected: viewModel.customization?.background == item.type,
                        onSelected: {
                            viewModel.customization = viewModel.customization?.copy(background: item.type)
                        }
                    )
                }
            }
            .padding(.bottom,50)
            .padding(.horizontal, 12)
        }
    }
}
