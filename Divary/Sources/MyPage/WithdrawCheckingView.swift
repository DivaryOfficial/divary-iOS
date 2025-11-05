//
//  WithdrawCheckingView.swift
//  Divary
//
//  Created by 김나영 on 11/6/25.
//

import SwiftUI

struct WithdrawCheckingView: View {
    @Environment(\.diContainer) private var di
    
    @State private var isChecked = false
    @State private var showWithdrawView = false

    var body: some View {
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
                        isChecked.toggle()
                    }) {
                        Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(isChecked ? Color.primary_sea_blue : .gray)
                            .font(.system(size: 22))
                    }

                    Text("다이버리 회원 탈퇴 유의사항을 확인했어요.")
                        .font(.NanumSquareNeo.NanumSquareNeoBold(size: 12))
                }
                .padding(.horizontal)

                Button(action: {
                    showWithdrawView = true
                }) {
                    Text("탈퇴하기")
                        .font(.omyu.regular(size: 20))
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .foregroundStyle(isChecked ? .white : Color.grayscale_g500)
                        .background(isChecked ? Color.primary_sea_blue : Color.grayscale_g100)
                        .cornerRadius(12)
                }
                .disabled(!isChecked)
                .padding(.horizontal)
            }
            .padding(.bottom, 32)
        }
        .fullScreenCover(isPresented: $showWithdrawView) {
            WithdrawView()
        }
        .navigationBarHidden(true)
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

#Preview {
    WithdrawCheckingView()
}
