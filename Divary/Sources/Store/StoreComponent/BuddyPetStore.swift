//
//  BuddyPetStore.swift
//  Divary
//
//  Created by 바견규 on 8/13/25.
//

import SwiftUI

struct BuddyPetStore: View {
    @Bindable var viewModel: CharacterViewModel
    @Binding var isPetEditingMode: Bool
    @State private var isFishSelected = false
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 22) {
            ScrollView {
                // 물고기를 제외한 펫들
                let nonFishPets = PetType.allCases.filter { $0 != .expectedGray && $0 != .expectedBlue }
                
                LazyVGrid(columns: columns, spacing: 16) {
                    // 나머지 펫들
                    ForEach(nonFishPets, id: \.self) { petType in
                        PetSelectionCard(
                            petType: petType,
                            viewModel: viewModel,
                            isFishSelected: $isFishSelected,
                            isPetEditingMode: $isPetEditingMode
                        )
                    }
                    
                    // 출시 예정
                    FishPetCard(
                        viewModel: viewModel,
                        isFishSelected: $isFishSelected
                    )
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}
