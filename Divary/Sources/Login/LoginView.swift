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
        GoogleSignInButtonView(action: viewModel.signInWithGoogle)
    }
}


#Preview {
    LoginView()
}
