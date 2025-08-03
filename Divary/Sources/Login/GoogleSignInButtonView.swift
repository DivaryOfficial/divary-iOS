//
//  GoogleSignInButtonView.swift
//  Divary
//
//  Created by 바견규 on 7/8/25.
//


import SwiftUI

//구글 로그인 버튼
struct GoogleSignInButtonView: View {
    var action: () -> Void
    @Environment(\.horizontalSizeClass) private var hSizeClass

    var body: some View {
        let isPad = hSizeClass == .regular
        let btnHeight: CGFloat = isPad ? 56 : 44
        let fontSize: CGFloat = isPad ? 16 : 14

        Button(action: action) {
            HStack(spacing: 12) {
                Image("google_g_logo")
                    .resizable()
                    .frame(width: 20, height: 20)
                Text("Continue with Google")
                    .font(Font.RobotoMedium.RobotoMedium(size: fontSize))
                    .foregroundStyle(Color.black)
            }
            .frame(height: btnHeight)
            .padding(.horizontal, 16)
            .background(
                   RoundedRectangle(cornerRadius: 8)
                     .fill(Color.white)
                     .shadow(color: Color.black.opacity(0.18), radius: 6, x: 0, y: 4)
            )
            .cornerRadius(4)
        }
    }
}


#Preview {
    VStack {
        Spacer()
        HStack {
            Spacer()
            Text("Preview")
            Spacer()
        }
        
        ZStack {
            GoogleSignInButtonView(action: {})
        }
        Spacer()
    }
    .background(Color.primary_sea_blue)
}
