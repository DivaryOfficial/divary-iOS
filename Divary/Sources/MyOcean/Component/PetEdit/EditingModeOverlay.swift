//
//  EditingOverlay.swift
//  Divary
//
//  Created by 바견규 on 8/13/25.
//

import SwiftUI

// MARK: - 편집 모드 오버레이
struct EditingModeOverlay: View {
    @Binding var isPetEditingMode: Bool
    @Binding var petDragOffset: CGSize
    @Binding var petTempRotation: Angle
    let viewModel: CharacterViewModel
    let impactFeedback: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            // 버튼들
            HStack {
                Spacer()
                
                VStack(spacing: 8) {
                    // 완료 버튼
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPetEditingMode = false
                        }
                        // 펫 편집 완료 시 서버에 저장
                        viewModel.saveAvatarToServer()
                        impactFeedback()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("완료")
                                .font(Font.omyu.regular(size: 16))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.primary_sea_blue)
                        )
                    }
                    
                    // 리셋 버튼
                    Button(action: {
                        withAnimation(.spring(response: 0.5)) {
                            if let customization = viewModel.customization {
                                let resetPet = PetCustomization(
                                    type: customization.pet.type,
                                    offset: .zero,
                                    rotation: .zero
                                )
                                viewModel.updatePet(resetPet)
                            }
                            petDragOffset = .zero
                            petTempRotation = .zero
                        }
                        impactFeedback()
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise.circle")
                            Text("리셋")
                                .font(Font.omyu.regular(size: 16))
                        }
                        .foregroundStyle(Color.primary_sea_blue)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .stroke(Color.primary_sea_blue, lineWidth: 1)
                        )
                    }
                }
                .padding(.trailing, 20)
            }
            .padding(.bottom, 50)
        }
    }
}
