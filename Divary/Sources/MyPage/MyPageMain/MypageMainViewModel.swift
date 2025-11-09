//
//  MypageViewModel.swift
//  Divary
//
//  Created by 바견규 on 11/9/25.
//

import SwiftUI

// MARK: - ViewModel
@MainActor
final class MyPageMainViewModel: ObservableObject {
    @Published var showLogoutPopup = false
    @Published var isLoading = false
    
    private let loginService: LoginService
    private let router: AppRouter
    
    init(loginService: LoginService, router: AppRouter) {
        self.loginService = loginService
        self.router = router
    }
    
    func logout() {
        // 저장된 socialType 가져오기
        guard let socialType = KeyChainManager.shared.read(forKey: KeyChainKey.socialType) else {
            print("❌ socialType이 없습니다. 강제 로그아웃 처리")
            clearUserDataAndNavigateToLogin()
            return
        }
        
        isLoading = true
        
        loginService.logout(socialType: socialType) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success:
                    print("✅ 로그아웃 성공")
                    self.clearUserDataAndNavigateToLogin()
                    
                case .failure(let error):
                    print("❌ 로그아웃 실패: \(error.localizedDescription)")
                    // 실패해도 로컬 데이터는 삭제하고 로그인 화면으로
                    self.clearUserDataAndNavigateToLogin()
                }
            }
        }
    }
    
    private func clearUserDataAndNavigateToLogin() {
        // 키체인에 저장된 토큰 삭제
        KeyChainManager.shared.delete(forKey: KeyChainKey.accessToken)
        KeyChainManager.shared.delete(forKey: KeyChainKey.refreshToken)
        KeyChainManager.shared.delete(forKey: KeyChainKey.socialType)
        
        // 팝업 닫기
        showLogoutPopup = false
        
        // 로그인 화면으로 이동
        router.popToRoot()
    }
}

// MARK: - Wrapper
struct MyPageMainViewWrapper: View {
    @Environment(\.diContainer) private var container
    
    var body: some View {
        MyPageMainView(diContainer: container)
    }
}
