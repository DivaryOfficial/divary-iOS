//
//  Handle.swift
//  Divary
//
//  Created by 바견규 on 8/13/25.
//

import SwiftUI

// MARK: - 모서리 핸들
struct CornerHandle: View {
    let offset: CGSize
    let scale: CGFloat
    
    var body: some View {
        let handleSize = 12 * scale  // 스케일 적용
        
        Circle()
            .fill(Color.white)
            .stroke(Color.primary_sea_blue, lineWidth: 1 * scale)  // 스케일 적용
            .frame(width: handleSize, height: handleSize)
            .offset(offset)
    }
}

// MARK: - 회전 핸들
struct RotationHandle: View {
    let offset: CGSize
    let scale: CGFloat
    @Binding var petTempRotation: Angle
    let viewModel: CharacterViewModel
    let impactFeedback: () -> Void
    
    var body: some View {
        let handleSize = 18 * scale  // 스케일 적용
        
        Circle()
            .fill(Color.white)
            .stroke(Color.primary_sea_blue, lineWidth: 1 * scale)  // 스케일 적용
            .frame(width: handleSize, height: handleSize)
            .overlay(
                Image(systemName: "arrow.clockwise")
                    .foregroundStyle(Color.primary_sea_blue)
                    .font(.system(size: 10 * scale, weight: .semibold))  // 스케일 적용
                    .scaleEffect(x: -1, y: 1)  // 좌우반전
            )
            .offset(offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let center = CGPoint.zero
                        let start = CGPoint(x: offset.width, y: offset.height)
                        let current = CGPoint(x: start.x + value.translation.width, y: start.y + value.translation.height)
                        
                        let startAngle = atan2(start.y - center.y, start.x - center.x)
                        let currentAngle = atan2(current.y - center.y, current.x - center.x)
                        
                        petTempRotation = .radians(Double(currentAngle - startAngle))
                    }
                    .onEnded { _ in
                        // 최종 회전 저장
                        if let customization = viewModel.customization {
                            let newRotation = customization.pet.rotation + petTempRotation
                            let updatedPet = PetCustomization(
                                type: customization.pet.type,
                                offset: customization.pet.offset,
                                rotation: newRotation
                            )
                            viewModel.updatePet(updatedPet)
                        }
                        petTempRotation = .zero
                        impactFeedback()
                    }
            )
    }
}
