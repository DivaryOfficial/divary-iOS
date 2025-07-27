//
//  SwiftUIView.swift
//  Divary
//
//  Created by 바견규 on 7/8/25.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import UIKit

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        ZStack {
            Image("loginBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        GoogleSignInButtonView(action: viewModel.signInWithGoogle)
                        Spacer()
                    }
                    
                    // 기기별로 다른 여백 적용
                    Spacer()
                        .frame(height: UIDevice.current.userInterfaceIdiom == .pad ?
                               geometry.size.height * 0.2 :
                               geometry.size.height * 0.1)
                }
            }
        }
    }
}


#Preview {
    LoginView()
}
