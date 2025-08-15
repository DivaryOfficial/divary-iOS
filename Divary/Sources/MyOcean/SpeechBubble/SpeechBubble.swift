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
    
    var body: some View {
        if customization.speechBubble != .none {
            if isStoreView {
                customization.speechBubble.inputView(text: viewModel.speechTextBinding)
                    .scaleEffect(scale)
                    .offset(x: (-100 * scale) + x, y: (-170 * scale) + y)
            } else {
                customization.speechBubble.view(text: customization.speechText ?? "")
                    .scaleEffect(scale)
                    .offset(x: (-100 * scale) + x, y: (-170 * scale) + y)
            }
        }
    }
}
