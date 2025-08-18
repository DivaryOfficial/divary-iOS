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
    let currentRotation: Angle  // 저장된 회전값
    let viewModel: CharacterViewModel
    let impactFeedback: () -> Void
    
    @State private var previousRotation: Angle?
    
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
                        // 중심점을 기준으로 한 회전 계산 (Stack Overflow 예제 방식)
                        let center = CGPoint.zero
                        
                        if let previousRotation = self.previousRotation {
                            let deltaY = value.location.y - center.y
                            let deltaX = value.location.x - center.x
                            let fingerAngle = Angle(radians: Double(atan2(deltaY, deltaX)))
                            let angle = fingerAngle - previousRotation
                            petTempRotation += angle
                            self.previousRotation = fingerAngle
                        } else {
                            let deltaY = value.location.y - center.y
                            let deltaX = value.location.x - center.x
                            let fingerAngle = Angle(radians: Double(atan2(deltaY, deltaX)))
                            previousRotation = fingerAngle
                        }
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
                        previousRotation = nil  // 리셋
                        impactFeedback()
                    }
            )
    }
}
