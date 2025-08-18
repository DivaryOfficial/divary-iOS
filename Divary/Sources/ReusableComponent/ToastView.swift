//
//  ToastView.swift
//  Divary
//
//  Created by 바견규 on 8/19/25.
//

import SwiftUI

// MARK: - Toast Message View
struct ToastView: View {
    let message: String
    @Binding var isShowing: Bool
    
    var body: some View {
        if isShowing {
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.red.opacity(0.9))
                .cornerRadius(20)
                .transition(.opacity)
                .zIndex(1000)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation {
                            isShowing = false
                        }
                    }
                }
        }
    }
}

