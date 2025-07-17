//
//  GoogleSignInButtonView.swift
//  Divary
//
//  Created by 바견규 on 7/8/25.
//


import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

//구글 로그인 버튼
struct GoogleSignInButtonView: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image("ios_light_sq_SI")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.6)
            }
        }
    }
}

#Preview {
    GoogleSignInButtonView(action: {})
}
