//
//  PetStoreComponents.swift
//  Divary
//
//  Created by 바견규 on 7/27/25.
//

import SwiftUI

// MARK: - Pet Store Components
struct FishPetCard: View {
    @Bindable var viewModel: CharacterViewModel
    @Binding var isFishSelected: Bool
    
    var body: some View {
        VStack(spacing: 19) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.grayscale_g100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isFishSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isFishSelected ? 3 : 1)
                    )

                // 물고기 이미지 (선택 상태에 따라 회색 또는 파랑)
                Image(isFishSelected ? PetType.expectedBlue.rawValue : PetType.expectedGray.rawValue)
                    .resizable()
                    .scaledToFit()
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(.horizontal, 44)
                    .padding(.vertical, 22)
            }
            
            HStack {
                // 물고기 이름
                Text("공개예정")
                    .font(Font.omyu.regular(size: 20))
                    .foregroundStyle(Color.bw_black)
                Spacer()
            }
            .padding(.top, 1)
        }
        .onTapGesture {
            // 물고기 선택 시
            withAnimation(.spring(response: 0.3)) {
                isFishSelected = true
            }
            
            // 실제 값은 .none으로 설정
            let currentPet = viewModel.customization?.pet ?? PetCustomization(type: .none)
            let newPet = PetCustomization(
                type: .none,  // 실제로는 .none
                offset: currentPet.offset,
                rotation: currentPet.rotation
            )
            viewModel.customization = viewModel.customization?.copy(pet: newPet)
        }
        .animation(.spring(response: 0.3), value: isFishSelected)
    }
}

struct PetSelectionCard: View {
    let petType: PetType
    @Bindable var viewModel: CharacterViewModel
    @Binding var isFishSelected: Bool
    @Binding var isPetEditingMode: Bool
    
    private var isSelected: Bool {
        viewModel.customization?.pet.type == petType
    }
    
    var body: some View {
        VStack(spacing: 19) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.white : Color.grayscale_g100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.primary_sea_blue : Color.grayscale_g300, lineWidth: 1)
                    )
                
                if petType == .none {
                    Image("StoreNone")
                        .font(.system(size: 80))
                        .foregroundStyle(Color.grayscale_g400)
                } else {
                    Image(petType.rawValue)
                        .resizable()
                        .scaledToFit()
                }
            }
            .padding(.top, 1)
            
            HStack {
                Text(petNameFor(petType))
                    .font(Font.omyu.regular(size: 20))
                    .foregroundStyle(Color.bw_black)
                Spacer()
            }
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.3)) {
                isFishSelected = false
            }

            let currentPet = viewModel.customization?.pet ?? PetCustomization(type: .none)
            let newPet = PetCustomization(
                type: petType,
                offset: currentPet.offset,
                rotation: currentPet.rotation
            )
            viewModel.customization = viewModel.customization?.copy(pet: newPet)

            // "없음"과 "출시예정"이 아닐 경우에만 편집 모드로 진입
            if petType != .none && petType != .expectedGray && petType != .expectedBlue {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isPetEditingMode = true
                }
            }
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
    
    private func petNameFor(_ petType: PetType) -> String {
        switch petType {
        case .none:
            return "없음"
        case .expectedGray, .expectedBlue:
            return "물고기"
        case .seahorse:
            return "아기해마"
        case .axolotl:
            return "우파루파"
        case .anglerFish:
            return "등불아귀"
        case .hermitCrab:
            return "소라게"
        }
    }
}
