//
//  SpeechBubble.swift
//  Divary
//
//  Created by 바견규 on 8/13/25.
//

import SwiftUI

// MARK: - 말풍선 뷰
struct SpeechBubbleView: View {
    let customization: CharacterCustomization
    let scale: CGFloat
    let x: CGFloat
    let y: CGFloat
    let isStoreView: Bool
    let viewModel: CharacterViewModel
    
    // 부유 애니메이션 상태
    @State private var floatingOffset: CGFloat = 0
    @State private var hasStartedAnimation = false  // 애니메이션 시작 여부 추적
    
    var body: some View {
        Group {
            if customization.speechBubble != .none {
                if isStoreView {
                    customization.speechBubble.inputView(text: viewModel.speechTextBinding)
                        .scaleEffect(scale)
                        .offset(x: (-100 * scale) + x, y: (-170 * scale) + y + floatingOffset)
                } else {
                    customization.speechBubble.view(text: customization.speechText ?? "")
                        .scaleEffect(scale)
                        .offset(x: (-100 * scale) + x, y: (-170 * scale) + y + floatingOffset)
                }
            }
        }
        .id("\(customization.speechBubble.rawValue)_floating") // 고유 ID 추가
        .onAppear {
            // pop으로 돌아올 때도 애니메이션이 시작되도록
            restartFloatingAnimation()
        }
        .onChange(of: customization.speechBubble) { _, _ in
            // 말풍선이 변경될 때 애니메이션 재시작
            restartFloatingAnimation()
        }
    }
    
    private func startFloatingAnimation() {
        guard !hasStartedAnimation else { return }
        hasStartedAnimation = true
        
        // 기존 애니메이션 정리
        floatingOffset = 0
        
        // 1초 지연 후 시작
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(
                Animation.easeInOut(duration: 2.8)
                    .repeatForever(autoreverses: true)
            ) {
                floatingOffset = -12
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
