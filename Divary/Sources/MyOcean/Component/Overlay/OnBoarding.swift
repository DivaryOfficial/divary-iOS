//
//  OnBoarding.swift
//  Divary
//
//  Created by 바견규 on 8/13/25.
//

import SwiftUI

// MARK: - 온보딩 뷰
struct OnboardingView: View {
    let customization: CharacterCustomization
    let geometry: GeometryProxy
    let keyboardHeight: CGFloat
    let viewModel: CharacterViewModel
    
    var body: some View {
        if customization.CharacterName == nil || customization.CharacterName?.isEmpty == true {
            HStack {
                Spacer()
                OnboardingMessageOverlay(userName: Binding(
                    get: { customization.CharacterName ?? "" },
                    set: { newValue in
                        viewModel.updateCharacterName(newValue)
                        viewModel.saveAvatarToServer()
                    }
                ))
                Spacer()
            }
            .offset(y: geometry.size.height * 0.2 - keyboardHeight / 2)
            .animation(.easeInOut(duration: 0.25), value: keyboardHeight)
        }
    }
}
