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
            TopBar(
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

                        Button(action: onTapEditProfile) {
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

// MARK: - Components

struct TopBar: View {
    @Environment(\.diContainer) private var di
    
    let isMainView: Bool
    let title: String
    var onBell: () -> Void

    var body: some View {
        ZStack {
            Text(title)
                .font(.omyu.regular(size: 20))
                .foregroundStyle(.primary)

            HStack {
                if !isMainView {
                    Button {
                        di.router.pop()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.black)
                            .frame(width: 44, height: 44, alignment: .leading) // 터치 영역 확보
                            .contentShape(Rectangle())
                    }
                } else {
                    Color.clear.frame(width: 44, height: 44)
                }
                Spacer()
                Button(action: onBell) {
                    Image("bell-1")
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, 2)
                        .contentShape(Rectangle())
                }
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

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
