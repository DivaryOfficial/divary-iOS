//
//  LoginViewModel.swift
//  Divary
//
//  Created by 바견규 on 7/8/25.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift
import UIKit

final class LoginViewModel: ObservableObject {
    @Published var userEmail: String?
    @Published var loginError: String?

    
    
    // 구글 로그인
    func signInWithGoogle() {
        // xcconfig에서 읽어오기
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_CLIENT_ID") as? String else {
            print("GOOGLE_CLIENT_ID 값 불러오기 실패")
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
            if let error = error {
                print("로그인 에러: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.loginError = error.localizedDescription
                }
                return
            }

            guard let user = result?.user else {
                print("사용자 정보 없음")
                DispatchQueue.main.async {
                    self.loginError = "사용자 정보 없음"
                }
                return
            }

            DispatchQueue.main.async {
                self.userEmail = user.profile?.email
                self.loginError = nil
                print("로그인 성공: \(self.userEmail ?? "-")")
                // idToken, accessToken 등 저장 로직 및 서버 API 호출
                // let idToken = user.idToken?.tokenString
            }
        }
    }
}
