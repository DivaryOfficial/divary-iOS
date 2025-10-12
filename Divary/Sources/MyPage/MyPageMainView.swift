//
//  MyPageMainView.swift
//  Divary
//
//  Created by 김나영 on 9/22/25.
//

import SwiftUI

struct MyPageMainView: View {
    @Environment(\.diContainer) private var di
    
    var userId: String = "user_id0123"
    var licenseSummary: String = "PADI 오픈워터 다이버 / 총 다이빙 횟수: 21회"

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
                        MyPageRow(icon: "humbleicons_verified", title: "나의 라이센스", isLast: false) {
                            di.router.push(.myLicense)
                        }
//                        MyPageRow(icon: "humbleicons_documents", title: "로그 모아보기", isLast: false, action: onTapLogs)
//                        MyPageRow(icon: "humbleicons_save", title: "임시저장 글", isLast: false, action: onTapDrafts)
                        MyPageRow(icon: "humbleicons_users", title: "나의 친구", isLast: true) {
                            di.router.push(.myFriend)
                        }
                    }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            Spacer()
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Component
private struct MyPageRow: View {
    let icon: String
    let title: String
    var isLast: Bool
    var action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: action) {
                HStack(spacing: 12) {
                    Image(icon)

                    Text(title)
                        .font(.omyu.regular(size: 20))
                        .foregroundStyle(.black)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(.tertiaryLabel))
                }
                .padding(.vertical, 14)
            }

            if !isLast {
                Divider()
            }
        }
    }
}

#Preview {
    MyPageMainView()
}
