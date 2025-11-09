//
//  MyPageMainView.swift
//  Divary
//
//  Created by 김나영 on 9/22/25.
//

import SwiftUI

// MARK: - View
struct MyPageMainView: View {
    @Environment(\.diContainer) private var di
    @StateObject private var viewModel: MyPageMainViewModel
    
    var userId: String = "user_id0123"
    var licenseSummary: String = "PADI 오픈워터 다이버 / 총 다이빙 횟수: 21회"
    
    init(diContainer: DIContainer) {
        _viewModel = StateObject(wrappedValue: MyPageMainViewModel(
            loginService: diContainer.loginService,
            router: diContainer.router
        ))
    }

    // 액션 콜백들
    var onTapEditProfile: () -> Void = {print("편집버튼")}
    var onTapBell: () -> Void = {}
    var onTapLicense: () -> Void = {print("라이선스버튼")}
    var onTapLogs: () -> Void = {}
    var onTapDrafts: () -> Void = {}
    var onTapFriends: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            MyPageTopBar(
                isMainView: true,
                title: "마이페이지",
                onBell: onTapBell
            )

            VStack(alignment: .leading, spacing: 0) {
                    // 프로필 요약
                    HStack(alignment: .center, spacing: 12) {
                        Image(.profile)
                            .resizable()
                            .frame(width: 25, height: 25)

                        VStack(alignment: .leading) {
                            Text(userId)
                                .font(.omyu.regular(size: 20))
                                .foregroundStyle(.primary)
                                .padding(.bottom, 2)
                            Text(licenseSummary)
                                .font(.omyu.regular(size: 16))
                                .foregroundStyle(Color(.grayscaleG400))
                        }

                        Spacer(minLength: 8)

                        Button {
                            di.router.push(.myProfile)
                        } label: {
                            Image("Vector")
                                .foregroundStyle(Color(.systemGray))
                        }
                    }
                    .padding(.vertical, 14)

                    Divider()

                    // 메뉴 리스트
                    VStack(spacing: 0) {
                        MyPageRow(icon: "humbleicons_verified", title: "나의 라이센스") {
                            di.router.push(.myLicense)
                        }
//                        MyPageRow(icon: "humbleicons_documents", title: "로그 모아보기", action: onTapLogs)
//                        MyPageRow(icon: "humbleicons_save", title: "임시저장 글", action: onTapDrafts)
                        MyPageRow(icon: "humbleicons_users", title: "나의 친구") {
                            di.router.push(.myFriend)
                        }
                        Divider().frame(height: 5)
                        MyPageRow(icon: "logout", title: "로그아웃") { 
                            viewModel.showLogoutPopup = true 
                        }
                        MyPageRow(icon: "withdraw", title: "회원탈퇴") {
                            di.router.push(.withdraw)
                        }
                        Divider().frame(height: 5)
                        CustomerCenter()
                        AppCare()
                    }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            Spacer()
        }
        .overlay {
            if viewModel.showLogoutPopup {
                DeletePopupView(
                    isPresented: $viewModel.showLogoutPopup,
                    deleteText: "로그아웃 하시겠어요?",
                    confirmText: "로그아웃",
                    onDelete: {
                        viewModel.logout()
                    }
                )
            }
            
            // 로딩 인디케이터
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

