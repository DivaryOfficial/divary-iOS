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
import AuthenticationServices

struct LoginWrapperView: View {
    @Environment(\.diContainer) private var container
    
    
    var body: some View {
        LoginView(loginService: container.loginService, router: container.router)
    }
}

struct LoginView: View {
    @Environment(\.diContainer) private var container
    @StateObject private var viewModel: LoginViewModel
    @State private var isCheckingToken = true
    
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
            
            if isCheckingToken {
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    
                    Text("로그인 확인 중...")
                        .font(.system(size: 14))
                        .foregroundStyle(.white)
                }
            } else {
                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        Button(action:{
                            KeyChainManager.shared.save("eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI0Iiwicm9sZSI6IlVTRVIiLCJ0eXBlIjoiYWNjZXNzIiwiaWF0IjoxNzY0MjA5MTc2LCJleHAiOjE3NjQyMTAwNzZ9.0ymLxARJUf76PJXIEyMPAUm9YV3xPhN424Dh_alluaQ", forKey: KeyChainKey.accessToken)
                            container.router.push(.MainTabBar)
                        }) {
                            Text("테스트 계정")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.gray.opacity(0.8))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal, 20)
                        
                        
                        HStack {
                            Spacer()
                            SignInWithAppleButton(
                                .signIn,
                                onRequest: { request in
                                    request.requestedScopes = [.fullName, .email]
                                },
                                onCompletion: { result in
                                    viewModel.signInWithApple(result: result)
                                }
                            )
                            .padding(.horizontal, 18)
                            .signInWithAppleButtonStyle(.white)
                            .cornerRadius(8)
                            .disabled(viewModel.isLoading)
                            .opacity(viewModel.isLoading ? 0.6 : 1.0)
                            
                            Spacer()
                        }.frame(height: 54)
                        
                        HStack {
                            Spacer()
                            GoogleSignInButtonView(action: viewModel.signInWithGoogle)
                                .padding(18)
                                .disabled(viewModel.isLoading)
                                .opacity(viewModel.isLoading ? 0.6 : 1.0)
                            Spacer()
                        }
                        
                        // 기기별로 다른 여백 적용
                        Spacer()
                            .frame(height: geometry.size.height * 0.1)
                    }
                }
            }
            
            // 로딩 오버레이
            if viewModel.isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    
                    Text("로그인 중...")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.7))
                )
            }
            
            // 토스트 메시지
            VStack {
                Spacer()
                ToastView(message: viewModel.toastMessage, isShowing: $viewModel.showToast)
                    .padding(.bottom, 100)
            }
        }
        .onAppear {
            if container.tokenManager.hasValidToken() {
                // 토큰이 유효하면 바로 메인 화면으로 이동
                container.router.push(.MainTabBar)
            } else {
                // 토큰이 없거나 유효하지 않으면 로그인 버튼들을 표시
                isCheckingToken = false
            }
        }
    }
    
    
    
    #Preview {
        LoginWrapperView()
    }
}
   
