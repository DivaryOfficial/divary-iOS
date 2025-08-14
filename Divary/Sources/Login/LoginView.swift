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

struct LoginWrapperView: View {
    @Environment(\.diContainer) private var container
    
    var body: some View {
        LoginView(loginService: container.loginService, router: container.router)
    }
}

struct LoginView: View {
    @Environment(\.diContainer) private var container
    @StateObject private var viewModel: LoginViewModel
    
    init(loginService: LoginService,  router: AppRouter) {
        // @StateObject는 wrappedValue를 통해 초기화해야 합니다
        _viewModel = StateObject(wrappedValue: LoginViewModel(loginService: loginService, router: router))
    }
    
    var body: some View {
        ZStack {
            Image("loginBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    Button(action: {
                        KeyChainManager.shared.save("eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJoeWVvbmd5dTIwMDJAZ21haWwuY29tIiwicm9sZSI6IlJPTEVfVVNFUiIsImlhdCI6MTc1NTE0OTY0OSwiZXhwIjoxNzU2NTg5NjQ5fQ.4Vf5BlC0mK59RQxZ0bnLqEcpn50sN1R7e3s0LawjL28", forKey: KeyChainKey.accessToken)
                        container.router.push(.MainTabBar)
                    }) {
                        Text("테스트 계정")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.8))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 20)
                    
                    HStack {
                        Spacer()
                        GoogleSignInButtonView(action: viewModel.signInWithGoogle)
                            .padding(18)
                        Spacer()
                    }
                    
                    // 로그인 에러 표시
                    if let errorMessage = viewModel.loginError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding()
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
    LoginWrapperView()
}
