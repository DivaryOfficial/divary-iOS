//
//  WithdrawCheckingView.swift
//  Divary
//
//  Created by 김나영 on 11/6/25.
//

import SwiftUI

// MARK: - ViewModel
@MainActor
final class WithdrawCheckingViewModel: ObservableObject {
    @Published var isChecked = false
    @Published var showWithdrawView = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let loginService: LoginService
    private let router: AppRouter
    
    init(loginService: LoginService, router: AppRouter) {
        self.loginService = loginService
        self.router = router
    }
    
    func deleteAccount() {
        isLoading = true
        errorMessage = nil
        
        loginService.deleteAccount { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    DebugLogger.success("회원 탈퇴 성공: 삭제 예정일 - \(response.scheduledDeletionAt)")
                    
                    // 저장된 토큰 및 사용자 정보 삭제
                    self.clearUserData()
                    
                    // 탈퇴 완료 화면으로 이동
                    self.showWithdrawView = true
                    
                case .failure(let error):
                    DebugLogger.error("회원 탈퇴 실패: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    
                    // 에러 알림 표시
                    self.router.alertMessage = "회원 탈퇴에 실패했습니다.\n\(error.localizedDescription)"
                    self.router.showAlert = true
                }
            }
        }
    }
    
    private func clearUserData() {
        // 키체인에 저장된 토큰 삭제
        KeyChainManager.shared.delete(forKey: KeyChainKey.accessToken)
        KeyChainManager.shared.delete(forKey: KeyChainKey.refreshToken)
        
        // 필요한 경우 다른 사용자 데이터도 삭제
        // UserDefaults 등에 저장된 데이터가 있다면 여기서 함께 삭제
    }
}

// MARK: - Wrapper
struct WithdrawCheckingViewWrapper: View {
    @Environment(\.diContainer) private var container
    
    var body: some View {
        WithdrawCheckingView(diContainer: container)
    }
}

// MARK: - View
struct WithdrawCheckingView: View {
    @Environment(\.diContainer) private var di
    @StateObject private var viewModel: WithdrawCheckingViewModel
    
    init(diContainer: DIContainer) {
        _viewModel = StateObject(wrappedValue: WithdrawCheckingViewModel(
            loginService: diContainer.loginService,
            router: diContainer.router
        ))
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 24) {
                ZStack {
                    HStack {
                        Button(action: { di.router.pop() }) {
                            Image(.chevronLeft)
                                .foregroundStyle(.black)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    }
                    
                    Text("회원 탈퇴")
                        .font(.omyu.regular(size: 20))
                }
                // 상단 타이틀
                VStack(alignment: .leading, spacing: 4) {
                    Text("탈퇴하기 전에 꼭 확인해주세요.")
                        .font(.NanumSquareNeo.NanumSquareNeoBold(size: 20))
                        .padding(.bottom, 4)
                    Text("탈퇴 후에는 복구가 불가능합니다.")
                        .font(.NanumSquareNeo.NanumSquareNeoBold(size: 12))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                InfoCard(
                    icon: "exclamationmark.triangle.fill",
                    title: "닉네임, 프로필 이미지, 나의 다이빙 레벨 등 계정 정보가 삭제돼요.",
                    subtitle: "다시 가입해도 이전 정보는 복구되지 않아요."
                )
                
                InfoCard(
                    icon: "doc.text.fill",
                    title: "로그북, 일기, 나의 바다 등 모든 기록이 영구 삭제돼요.",
                    subtitle: "탈퇴하면 어떤 방법으로도 되돌릴 수 없어요."
                )
                
                Spacer()
                
                // 체크박스 + 버튼
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Button(action: {
                            viewModel.isChecked.toggle()
                        }) {
                            Image(systemName: viewModel.isChecked ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(viewModel.isChecked ? Color.primary_sea_blue : .gray)
                                .font(.system(size: 22))
                        }
                        
                        Text("다이버리 회원 탈퇴 유의사항을 확인했어요.")
                            .font(.NanumSquareNeo.NanumSquareNeoBold(size: 12))
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        viewModel.deleteAccount()
                    }) {
                        Text("탈퇴하기")
                            .font(.omyu.regular(size: 20))
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .foregroundStyle(viewModel.isChecked ? .white : Color.grayscale_g500)
                            .background(viewModel.isChecked ? Color.primary_sea_blue : Color.grayscale_g100)
                            .cornerRadius(12)
                    }
                    .disabled(!viewModel.isChecked || viewModel.isLoading)
                    .padding(.horizontal)
                }
                .padding(.bottom, 32)
            }
            .fullScreenCover(isPresented: $viewModel.showWithdrawView) {
                WithdrawView()
            }
            .navigationBarHidden(true)
            
            // 로딩 인디케이터
            if viewModel.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
    }
    
    private struct InfoCard: View {
        let icon: String
        let title: String
        let subtitle: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(.grayscale_g500)
                HStack(alignment: .top/*, spacing: 8*/) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.omyu.regular(size: 18))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineSpacing(4)
                        Text(subtitle)
                            .font(.omyu.regular(size: 16))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.grayscaleG300), lineWidth: 1)
                    )
            )
            .padding(.horizontal)
        }
    }
}

#Preview {
    let router = AppRouter()
    let container = DIContainer(router: router)
    
    WithdrawCheckingView(diContainer: container)
        .environment(\.diContainer, container)
}
