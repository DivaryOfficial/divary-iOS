//
//  Loading.swift
//  Divary
//
//  Created by 바견규 on 8/13/25.
//

import SwiftUI

// MARK: - 로딩 오버레이
struct LoadingOverlay: View {
    var message: String = "로딩 중..."
    var showBackground: Bool = false
    
    var body: some View {
        ZStack {
            // 배경 (필요한 경우에만)
            if showBackground {
                Image("seaBack")
                    .resizable()
                    .ignoresSafeArea()
                    .scaledToFill()
            } else {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 16) {
//                ProgressView()
//                    .scaleEffect(1.2)
//                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                
//                Text(message)
//                    .foregroundStyle(.white)
//                    .font(.system(size: 16, weight: .medium))
//            }
//            .padding(24)
//            .background(
//                RoundedRectangle(cornerRadius: 12)
//                    .fill(Color.black.opacity(0.8))
//            )
                ProgressView(message)
                    .progressViewStyle(CircularProgressViewStyle())
                    .foregroundStyle(.black)
                    .padding()
            }
        }
    }
}
