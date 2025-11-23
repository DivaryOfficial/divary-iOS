//
//  SplashView.swift
//  Divary
//
//  Created on 11/23/25.
//

import SwiftUI

struct SplashView: View {
    @State private var opacity = 1.0
    @Environment(\.diContainer) private var container
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image("loginBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }
            .opacity(opacity)
        }
        .task {
            DivaryFontFamily.registerAllCustomFonts()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 0.3)) {
                    opacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    container.router.push(.login)
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
