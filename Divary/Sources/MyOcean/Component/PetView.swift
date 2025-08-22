//
//  PetView.swift
//  Divary
//
//  Created by 바견규 on 8/13/25.
//

import SwiftUI

// MARK: - 펫 뷰
struct PetView: View {
    let customization: CharacterCustomization
    let scale: CGFloat
    let x: CGFloat
    let y: CGFloat
    let geometry: GeometryProxy
    @Binding var isPetEditingMode: Bool
    @Binding var petDragOffset: CGSize
    @Binding var petTempRotation: Angle
    let viewModel: CharacterViewModel
    let impactFeedback: () -> Void

    // 기준 스케일 정의 (iPhone 16 Pro 기준)
    private let baseScale: CGFloat = 1.0
    
    // 부유 애니메이션 상태
    @State private var floatingOffset: CGFloat = 0
    @State private var hasStartedAnimation = false  // 애니메이션 시작 여부 추적
    
    var body: some View {
        // 펫이 none이 아닌 경우에만 표시
        if customization.pet.type != .none {
            let baseFrameSize: CGFloat = 160
            let frameSize = baseFrameSize * scale  // 스케일 적용
            
            // 펫의 최종 위치 계산 - 기준 스케일로 정규화
            let normalizedOffsetX = customization.pet.offset.width * scale / baseScale
            let normalizedOffsetY = customization.pet.offset.height * scale / baseScale
            let finalX = normalizedOffsetX + x + petDragOffset.width
            let finalY = normalizedOffsetY + y + petDragOffset.height
            let finalRotation = customization.pet.rotation + petTempRotation
            
            ZStack {
                if isPetEditingMode {
                    // 편집 모드 - 부유 효과 없음 (드래그와 충돌 방지)
                    ZStack {
                        // 회전되는 부분 (프레임 + 펫 + 모서리 핸들)
                        Group {
                            // 선택 프레임
                            RoundedRectangle(cornerRadius: 8 * scale)
                                .stroke(Color.primary_sea_blue, lineWidth: 2 * scale)
                                .frame(width: frameSize + (10 * scale), height: frameSize + (10 * scale))
                                .background(
                                    RoundedRectangle(cornerRadius: 8 * scale)
                                        .fill(Color.primary_sea_blue.opacity(0.1))
                                )
                            
                            // 펫 이미지
                            Image(customization.pet.type.rawValue)
                                .resizable()
                                .frame(width: frameSize, height: frameSize)
                            
                            // 모서리 핸들들
                            Group {
                                CornerHandle(
                                    offset: CGSize(width: -frameSize/2 - (5 * scale), height: -frameSize/2 - (5 * scale)),
                                    scale: scale
                                )
                                CornerHandle(
                                    offset: CGSize(width: frameSize/2 + (5 * scale), height: -frameSize/2 - (5 * scale)),
                                    scale: scale
                                )
                                CornerHandle(
                                    offset: CGSize(width: -frameSize/2 - (5 * scale), height: frameSize/2 + (5 * scale)),
                                    scale: scale
                                )
                            }
                        }
                        .rotationEffect(finalRotation)
                        
                        // 회전 핸들
                        RotationHandle(
                            offset: rotatedHandleOffset(
                                baseOffset: CGSize(width: frameSize/2 + (5 * scale), height: frameSize/2 + (5 * scale)),
                                rotation: finalRotation
                            ),
                            scale: scale,
                            petTempRotation: $petTempRotation,
                            currentRotation: customization.pet.rotation,
                            viewModel: viewModel,
                            impactFeedback: impactFeedback
                        )
                    }
                    .offset(x: finalX, y: finalY)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                petDragOffset = value.translation
                            }
                            .onEnded { _ in
                                // 기준 스케일로 정규화해서 저장
                                let normalizedOffsetX = (customization.pet.offset.width * scale / baseScale + petDragOffset.width) * baseScale / scale
                                let normalizedOffsetY = (customization.pet.offset.height * scale / baseScale + petDragOffset.height) * baseScale / scale
                                
                                let newOffset = CGSize(
                                    width: normalizedOffsetX,
                                    height: normalizedOffsetY
                                )
                                let updatedPet = PetCustomization(
                                    type: customization.pet.type,
                                    offset: newOffset,
                                    rotation: customization.pet.rotation
                                )
                                viewModel.updatePet(updatedPet)
                                petDragOffset = .zero
                                impactFeedback()
                            }
                    )
                    
                } else {
                    // 일반 모드 - 부유 효과 적용
                    Image(customization.pet.type.rawValue)
                        .resizable()
                        .frame(width: frameSize, height: frameSize)
                        .rotationEffect(customization.pet.rotation)
                        .offset(x: normalizedOffsetX + x,
                               y: normalizedOffsetY + y + floatingOffset)
                        .onTapGesture(count: 2) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isPetEditingMode = true
                            }
                            impactFeedback()
                        }
                }
            }
            .id("\(customization.pet.type.rawValue)_floating") // 고유 ID 추가
            .onAppear {
                // pop으로 돌아올 때도 애니메이션이 시작되도록
                restartFloatingAnimation()
            }
            .onChange(of: customization.pet.type) { _, _ in
                // 펫이 변경될 때 애니메이션 재시작
                restartFloatingAnimation()
            }
        }
    }
    
    private func startFloatingAnimation() {
        guard !hasStartedAnimation else { return }
        hasStartedAnimation = true
        
        // 기존 애니메이션 정리
        floatingOffset = 0
        
        // 0.5초 지연 후 시작 (캐릭터와 다른 타이밍)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(
                Animation.easeInOut(duration: 2.5)
                    .repeatForever(autoreverses: true)
            ) {
                floatingOffset = -15
            }
        }
    }
    
    private func restartFloatingAnimation() {
        // 기존 애니메이션 즉시 중단 및 상태 리셋
        withAnimation(.linear(duration: 0)) {
            floatingOffset = 0
        }
        hasStartedAnimation = false
        
        // 즉시 새 애니메이션 시작 (pop으로 돌아올 때는 지연 없이)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            startFloatingAnimation()
        }
    }
    
    // 회전된 좌표계에서 핸들 위치 계산
    private func rotatedHandleOffset(baseOffset: CGSize, rotation: Angle) -> CGSize {
        let radians = rotation.radians
        let cos_r = cos(radians)
        let sin_r = sin(radians)
        
        let rotatedX = baseOffset.width * cos_r - baseOffset.height * sin_r
        let rotatedY = baseOffset.width * sin_r + baseOffset.height * cos_r
        
        return CGSize(width: rotatedX, height: rotatedY)
    }
}
