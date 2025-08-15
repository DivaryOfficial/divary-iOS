//
//  DiverItemStore.swift
//  Divary
//
//  Created by 바견규 on 8/13/25.
//

import SwiftUI

struct DiverItemStore: View {
    @Bindable var viewModel: CharacterViewModel
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16) {
                MaskSection(viewModel: viewModel)
                
                RegulatorSection(viewModel: viewModel)
                
                PinSection(viewModel: viewModel)
                
                TankSection(viewModel: viewModel)
            }
            .padding(.top)
            .padding(.bottom, 50)
            .padding(.horizontal, 12)
        }
    }
}

// MARK: - 마스크 섹션
struct MaskSection: View {
    @Bindable var viewModel: CharacterViewModel
    
    var body: some View {
        ItemSelectionSection(
            title: "마스크",
            items: MaskType.allCases,
            selectedItem: viewModel.customization?.mask,
            imageWidth: 67,
            noneSize: 40,
            noneHorizontalPadding: 24,
            noneVerticalPadding: 11
        ) { selected in
            viewModel.customization = viewModel.customization?.copy(mask: selected)
        }
    }
}

// MARK: - 레귤레이터 섹션
struct RegulatorSection: View {
    @Bindable var viewModel: CharacterViewModel
    
    var body: some View {
        ItemSelectionSection(
            title: "레귤레이터",
            items: RegulatorType.allCases,
            selectedItem: viewModel.customization?.regulator,
            imageWidth: 67,
            noneSize: 40,
            noneHorizontalPadding: 26,
            noneVerticalPadding: 12
        ) { selected in
            viewModel.customization = viewModel.customization?.copy(regulator: selected)
        }
    }
}

// MARK: - 핀 섹션
struct PinSection: View {
    @Bindable var viewModel: CharacterViewModel
    
    var body: some View {
        ItemSelectionSection(
            title: "핀",
            items: PinType.allCases,
            selectedItem: viewModel.customization?.pin,
            imageWidth: 67,
            noneSize: 60,
            noneHorizontalPadding: 12,
            noneVerticalPadding: 12
        ) { selected in
            viewModel.customization = viewModel.customization?.copy(pin: selected)
        }
    }
}

// MARK: - 탱크 섹션
struct TankSection: View {
    @Bindable var viewModel: CharacterViewModel
    
    var body: some View {
        ItemSelectionSection(
            title: "탱크",
            items: TankType.allCases,
            selectedItem: viewModel.customization?.tank,
            imageWidth: 67,
            noneSize: 70,
            noneHorizontalPadding: 9,
            noneVerticalPadding: 15
        ) { selected in
            viewModel.customization = viewModel.customization?.copy(tank: selected)
        }
    }
}
