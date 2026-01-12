//
//  LoginViewModel.swift
//  Divary
//
//  Created by 바견규 on 7/8/25.
//

import Foundation
import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices
import UIKit

final class LoginViewModel: ObservableObject {
    @Published var userEmail: String?
    @Published var loginError: String?
    @Published var isLoading: Bool = false
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    
    private let loginService: LoginService
    private let router: AppRouter // AppRouter 추가
    private var deviceID: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }

        
    init(loginService: LoginService, router: AppRouter) {
        self.loginService = loginService
        self.router = router
    }
    
    // 토스트 메시지 표시 헬퍼 메서드
    private func showToastMessage(_ message: String) {
        DispatchQueue.main.async {
            self.toastMessage = message
            self.loginError = message
            self.isLoading = false
            
            withAnimation {
                self.showToast = true
            }
            
            DebugLogger.log(message)
        }
    }
    
    //애플로그인
    func signInWithApple(result: Result<ASAuthorization, Error>) {
        isLoading = true
        loginError = nil
        
        DebugLogger.log("애플 로그인 시작")
        
        switch result {
        case .success(let auth):
            // 1. 인증 정보에서 credential 가져오기
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential else {
                showToastMessage("Apple 자격 증명을 가져오는데 실패했습니다.")
                return
            }
            
            DebugLogger.success("Apple 자격 증명 획득 성공")
            
            // 2. 서버 검증에 필요한 identityToken 가져오기
            guard let identityTokenData = credential.identityToken,
                  let identityToken = String(data: identityTokenData, encoding: .utf8) else {
                showToastMessage("identityToken을 변환하는데 실패했습니다.")
                return
            }
            
            DebugLogger.success("identityToken 변환 성공")
            DebugLogger.log("서버에 애플 로그인 요청 중...")
            
            // 3. 서버에 identityToken을 보내 로그인/회원가입 처리
            self.loginService.appleLogin(identityToken: identityToken, deviceId: self.deviceID) { result in
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    DebugLogger.log("identityToken:\n\(identityToken)\n\ndeviceID:\n\(self.deviceID)")
                    switch result {
                    case .success(let response):
                        DebugLogger.success("애플 로그인 서버 인증 성공")
                        DebugLogger.log("   AccessToken: \(response.accessToken)")
                        DebugLogger.log("   RefreshToken: \(response.refreshToken)")
                        
                        KeyChainManager.shared.save(response.accessToken, forKey: KeyChainKey.accessToken)
                        KeyChainManager.shared.save(response.refreshToken, forKey: KeyChainKey.refreshToken)
                        KeyChainManager.shared.save("APPLE", forKey: KeyChainKey.socialType)
                        
                        self.loginError = nil
                        self.router.push(.MainTabBar)
                        
                    case .failure(let error):
                        DebugLogger.error("서버 애플 로그인 실패: \(error)")
                        
                        // APIError 타입에 따라 다른 메시지 표시
                        var errorMsg = "서버 인증에 실패했습니다."
                        if case let .responseState(_, code, message) = error {
                            errorMsg = "[\(code)] \(message)"
                        } else {
                            errorMsg = error.localizedDescription
                        }
                        
                        self.showToastMessage(errorMsg)
                    }
                }
            }
            
        case .failure(let error):
            DebugLogger.error("애플 로그인 실패: \(error.localizedDescription)")
            
            // 사용자가 취소한 경우 토스트를 띄우지 않음
            let nsError = error as NSError
            if nsError.domain == ASAuthorizationError.errorDomain,
               nsError.code == ASAuthorizationError.canceled.rawValue {
                DispatchQueue.main.async {
                    self.isLoading = false
                    DebugLogger.log("사용자가 애플 로그인을 취소했습니다.")
                }
            } else {
                showToastMessage("애플 로그인에 실패했습니다.")
            }
        }
    }
    
    // 구글 로그인
    func signInWithGoogle() {
        isLoading = true
        loginError = nil
        
        DebugLogger.log("구글 로그인 시작")
        
        // xcconfig에서 읽어오기
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_CLIENT_ID") as? String else {
            DebugLogger.error("GOOGLE_CLIENT_ID 값 불러오기 실패")
            showToastMessage("Google Client ID를 찾을 수 없습니다.")
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            showToastMessage("화면을 찾을 수 없습니다.")
            return
        }
        
        DebugLogger.log("구글 로그인 UI 표시 중...")
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
            if let error = error {
                DebugLogger.error("구글 로그인 에러: \(error.localizedDescription)")
                
                // 사용자가 취소한 경우 토스트를 띄우지 않음
                let nsError = error as NSError
                if nsError.code == -5 { // GIDSignInErrorCode.canceled
                    DispatchQueue.main.async {
                        self.isLoading = false
                        DebugLogger.log("사용자가 구글 로그인을 취소했습니다.")
                    }
                } else {
                    self.showToastMessage("구글 로그인에 실패했습니다.")
                }
                return
            }
            
            guard let user = result?.user else {
                DebugLogger.warning("사용자 정보 없음")
                self.showToastMessage("사용자 정보를 가져올 수 없습니다.")
                return
            }
            
            DebugLogger.success("구글 로그인 성공")
            DebugLogger.log("   Email: \(user.profile?.email ?? "N/A")")
            DebugLogger.log("   Google AccessToken: \(user.accessToken.tokenString)")
            DebugLogger.log("서버에 구글 로그인 요청 중...")
            
            DispatchQueue.main.async {
                self.userEmail = user.profile?.email
                
                // idToken, accessToken 등 저장 로직 및 서버 API 호출
                self.loginService.googleLogin(accessToken: user.accessToken.tokenString, deviceId: self.deviceID, completion: { result in
                    DispatchQueue.main.async {
                        self.isLoading = false
                        
                        switch result {
                        case .success(let response):
                            DebugLogger.success("구글 로그인 서버 인증 성공")
                            DebugLogger.log("   AccessToken: \(response.accessToken)")
                            DebugLogger.log("   RefreshToken: \(response.refreshToken)")
                            DebugLogger.log("   DeviceId: \(self.deviceID)")
                            
                            KeyChainManager.shared.save(response.accessToken, forKey: KeyChainKey.accessToken)
                            KeyChainManager.shared.save(response.refreshToken, forKey: KeyChainKey.refreshToken)
                            KeyChainManager.shared.save("GOOGLE", forKey: KeyChainKey.socialType)
                            
                            self.loginError = nil
                            self.router.push(.MainTabBar)
                            
                        case .failure(let error):
                            DebugLogger.error("서버 로그인 실패: \(error)")
                            
                            // APIError 타입에 따라 다른 메시지 표시
                            var errorMsg = "서버 인증에 실패했습니다."
                            if case let .responseState(_, code, message) = error {
                                errorMsg = "[\(code)] \(message)"
                            } else {
                                errorMsg = error.localizedDescription
                            }
                            
                            self.showToastMessage(errorMsg)
                        }
                    }
                })
            }
        }
    }
}
