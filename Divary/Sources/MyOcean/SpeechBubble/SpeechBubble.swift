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
    let viewModel: CharacterViewModel  // viewModel 추가
    
    // 부유 애니메이션 상태
    @State private var floatingOffset: CGFloat = 0
    
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
        .task {
            startFloatingAnimation()
        }
    }
    
    private func startFloatingAnimation() {
        // 1초 지연 후 시작 (다른 요소들과 다른 타이밍)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(
                Animation.easeInOut(duration: 2.8)
                    .repeatForever(autoreverses: true)
            ) {
                floatingOffset = -12
            }
        }
    }
}
