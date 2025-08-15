//
//  LoadingOverlay.swift
//  Divary
//
//  Created by 김나영 on 8/15/25.
//

import SwiftUI

struct LoadingOverlay: View {
    let text: String

    var body: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
            ProgressView(text)
                .progressViewStyle(CircularProgressViewStyle())
                .foregroundColor(.black)
                .padding()
//                .background(Color.black.opacity(0.5))
                .cornerRadius(10)
        }
        .transition(.opacity)
        .zIndex(999)
    }
}

#Preview {
    LoadingOverlay(text: "로딩 중...")
}
