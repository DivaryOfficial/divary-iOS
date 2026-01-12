//
//  MypageViewModel.swift
//  Divary
//
//  Created by 바견규 on 11/9/25.
//

import SwiftUI
import Combine

// MARK: - ViewModel
@MainActor
final class MyPageMainViewModel: ObservableObject {
    @Published var showLogoutPopup = false
    @Published var isLoading = false
    
    @Published var userId: String = "로딩 중..."
    @Published var licenseSummary: String = "정보를 불러오는 중..."
    
    private let loginService: LoginService
    private let router: AppRouter
    private let memberService: MemberService
    
    private var cancellables = Set<AnyCancellable>()
    
    init(loginService: LoginService, router: AppRouter, memberService: MemberService) {
        self.loginService = loginService
        self.router = router
        self.memberService = memberService

    }
    
    func fetchProfile() {
        // 로그아웃 로딩과는 별개로 isLoading을 사용할 수 있으나,
        // 여기서는 프로필 로드 시에도 로딩 인디케이터를 사용하지 않는 것으로 가정합니다.
        // 만약 로딩이 필요하다면 별도의 @Published var isProfileLoading = false 를 추가하세요.
        
        memberService.getProfile()
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    DebugLogger.error("MyPageMain/getProfile 에러: \(error.localizedDescription)")
                    self?.userId = "에러 발생"
                    self?.licenseSummary = "정보를 불러오지 못했습니다."
                }
            }, receiveValue: { [weak self] profile in
                guard let self = self else { return }
                
                // 5. API 응답(String)을 한글 레벨(String)으로 변환
                // (MyProfileView의 DiveLevel enum 로직을 가져와 여기서 처리)
                let levelString = self.mapApiLevelToKorean(apiLevel: profile.level ?? "")
                
                // 6. @Published 프로퍼티 업데이트 (View가 갱신됨)
                self.userId = profile.id
                self.licenseSummary = "\(profile.memberGroup ?? "미설정") \(levelString) / 총 다이빙 횟수: \(profile.accumulations)회"
                
                DebugLogger.success("마이페이지 프로필 로드 성공")
            })
            .store(in: &cancellables)
    }
    
    func logout() {
        // 저장된 socialType 가져오기
        guard let socialType = KeyChainManager.shared.read(forKey: KeyChainKey.socialType) else {
            DebugLogger.error("socialType이 없습니다. 강제 로그아웃 처리")
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
                    DebugLogger.success("로그아웃 성공")
                    self.clearUserDataAndNavigateToLogin()
                    
                case .failure(let error):
                    DebugLogger.error("로그아웃 실패: \(error.localizedDescription)")
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
    
    private func mapApiLevelToKorean(apiLevel: String) -> String {
        switch apiLevel {
        case "OPEN_WATER_DIVER": return "오픈워터 다이버"
        case "ADVANCED_OPEN_WATER_DIVER": return "어드밴스드 오픈워터 다이버"
        case "RESCUE_DIVER": return "레스큐 다이버"
        case "DIVE_MASTER": return "다이브마스터"
        case "ASSISTANT_INSTRUCTOR": return "어시스턴트 인스트럭터"
        case "INSTRUCTOR": return "인스트럭터"
        default: return apiLevel // 매핑되는 값이 없으면 API 원본 값 반환
        }
    }
}

// MARK: - Wrapper
struct MyPageMainViewWrapper: View {
    @Environment(\.diContainer) private var container
    
    var body: some View {
        MyPageMainView(diContainer: container)
    }
}
