//
//  dismissButton.swift
//  Divary
//
//  Created by 바견규 on 12/30/25.
//


import SwiftUI

// MARK: - 상점 버튼
struct DismissButton: View {
    let scale: CGFloat
    let scaleX: CGFloat
    let scaleY: CGFloat
    let x: CGFloat
    let y: CGFloat
    let container: DIContainer
    let viewModel: CharacterViewModel
    
    var body: some View {
        Button(action: {
            container.router.pop()
            print("뒤로가기 버튼 클릭")
        }) {
            Image("chevron.left")
                .resizable()
                .frame(width:30, height: 30)
                .scaleEffect(scale)
                .foregroundStyle(Color(.bWBlack))
        }
        .offset(x: (-190 * scaleX) + x, y: (-240 * scaleY) + y)
        .zIndex(1000)
    }
}


