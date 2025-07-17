//
//  SwiftUIView.swift
//  Divary
//
//  Created by 바견규 on 7/8/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        ZStack {
            Image("Login_Background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            VStack{
                
                Spacer()
                
                GoogleSignInButtonView(action: viewModel.signInWithGoogle)
                    .padding(.bottom, 84)
            }
                
        }
        
    }
}


#Preview {
    LoginView()
}
