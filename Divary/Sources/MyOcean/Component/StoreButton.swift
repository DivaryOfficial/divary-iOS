//
//  StoreButton.swift
//  Divary
//
//  Created by 바견규 on 8/13/25.
//


import SwiftUI

// MARK: - 상점 버튼
struct StoreButton: View {
    let scale: CGFloat
    let scaleX: CGFloat
    let scaleY: CGFloat
    let x: CGFloat
    let y: CGFloat
    let container: DIContainer
    let viewModel: CharacterViewModel
    
    var body: some View {
        Button(action: {
            container.router.push(.Store(viewModel: viewModel))
            print("상점 버튼 클릭")
        }) {
            Image("storeIcon")
                .resizable()
                .frame(width:30, height: 30)
                .scaleEffect(scale)
        }
        .offset(x: (150 * scaleX) + x, y: (-240 * scaleY) + y)
        .zIndex(1000)
    }
}
