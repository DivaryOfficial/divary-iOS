//
//  LogBookNavBar.swift
//  Divary
//
//  Created by 바견규 on 7/9/25.
//

import SwiftUI

struct LogBookNavBar: View {
    var body: some View {
        HStack(spacing: 8) {
            // 왼쪽: 뒤로가기
            Button(action: {
                // 뒤로가기 로직
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.black)
            }

            Spacer()

            // 가운데: 날짜 + 자물쇠
            HStack(spacing: 4) {
                Text("2025.07.25 일요일")
                    .font(Font.omyu.regular(size: 20))
                    .foregroundColor(.black)

                Image(systemName: "lock.fill")
                    .resizable()
                    .frame(width: 10, height: 12)
                    .foregroundColor(.black)
            }

            Spacer()

            // 오른쪽: 저장 (비활성화 스타일)
            Text("저장")
                .font(Font.omyu.regular(size: 20))
                .foregroundColor(.gray) // 비활성화 느낌
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.white)
    }
}


#Preview {
    LogBookNavBar()
}
