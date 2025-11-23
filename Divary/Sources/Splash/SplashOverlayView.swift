//
//  SplashView.swift
//  Divary
//
//  Created on 11/23/25.
//

import SwiftUI

struct SplashOverlayView: View {
    @Binding var isShowing: Bool
    @State private var opacity = 1.0
    
    var body: some View {
        ZStack {
            // 배경색 (원하는 색으로 변경하세요)
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // 여기에 스플래시 이미지를 넣으세요
                // Image("splash_logo")
                //     .resizable()
                //     .scaledToFit()
                //     .frame(width: 200, height: 200)
                
                Text("Divary")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
        }
        .opacity(opacity)
        .onAppear {
            // 2초 후 스플래시 화면 사라짐
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 0.3)) {
                    opacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isShowing = false
                }
            }
        }
    }
}

#Preview {
    SplashOverlayView(isShowing: .constant(true))
}
