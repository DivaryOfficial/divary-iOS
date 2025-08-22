//
//  Character.swift
//  Divary
//
//  Created by 바견규 on 8/13/25.
//

import SwiftUI

// MARK: - 캐릭터 장비 뷰
struct CharacterEquipmentView: View {
    let customization: CharacterCustomization
    let scale: CGFloat
    let x: CGFloat
    let y: CGFloat
    let onTap: (() -> Void)?
    
    // 부유 애니메이션 상태
    @State private var floatingOffset: CGFloat = 0
    @State private var hasStartedAnimation = false  // 애니메이션 시작 여부 추적
    
    init(customization: CharacterCustomization, scale: CGFloat, x: CGFloat, y: CGFloat, onTap: (() -> Void)? = nil) {
        self.customization = customization
        self.scale = scale
        self.x = x
        self.y = y
        self.onTap = onTap
    }
    
    var body: some View {
        ZStack {
            // 산소통
            if customization.tank != .none {
                Image(customization.tank.rawValue)
                    .scaleEffect(scale)
                    .offset(x: (70 * scale) + x, y: (-10 * scale) + y + floatingOffset)
                    .onTapGesture {
                        onTap?()
                    }
            }
            
            // 몸통 (기본으로 항상 표시)
            if customization.body != .none {
                Image(customization.body.rawValue)
                    .scaleEffect(scale)
                    .offset(x: x, y: y + floatingOffset)
                    .onTapGesture {
                        onTap?()
                    }
            }
            
            // 호흡기
            if customization.regulator != .none {
                Image(customization.regulator.rawValue)
                    .scaleEffect(scale)
                    .offset(x: (-65 * scale) + x, y: (-30 * scale) + y + floatingOffset)
                    .onTapGesture {
                        onTap?()
                    }
            }
            
            // 볼터치
            if customization.cheek != .none {
                Image(customization.cheek.rawValue)
                    .scaleEffect(scale)
                    .offset(x: (-45 * scale) + x, y: (-40 * scale) + y + floatingOffset)
                    .onTapGesture {
                        onTap?()
                    }
            }
            
            // 마스크
            if customization.mask != .none {
                Image(customization.mask.rawValue)
                    .scaleEffect(scale)
                    .offset(x: (-28 * scale) + x, y: (-60 * scale) + y + floatingOffset)
                    .onTapGesture {
                        onTap?()
                    }
            }
            
            // 핀
            if customization.pin != .none {
                Image(customization.pin.rawValue)
                    .scaleEffect(scale)
                    .offset(x: (68 * scale) + x, y: (85 * scale) + y + floatingOffset)
                    .onTapGesture {
                        onTap?()
                    }
            }
        }
        .id("character_equipment_floating") // 고유 ID 추가
        .onAppear {
            // pop으로 돌아올 때도 애니메이션이 시작되도록
            restartFloatingAnimation()
        }
        .onChange(of: [customization.tank.rawValue, customization.body.rawValue,
                      customization.regulator.rawValue, customization.cheek.rawValue,
                      customization.mask.rawValue, customization.pin.rawValue]) { _, _ in
            // 장비가 변경될 때 애니메이션 재시작
            restartFloatingAnimation()
        }
    }
    
    private func startFloatingAnimation() {
        guard !hasStartedAnimation else { return }
        hasStartedAnimation = true
        
        // 기존 애니메이션 정리
        floatingOffset = 0
        
        // 즉시 시작 (캐릭터는 지연 없음)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(
                Animation.easeInOut(duration: 3.0)
                    .repeatForever(autoreverses: true)
            ) {
                floatingOffset = -20
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
}
