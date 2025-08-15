//
//  StickerFooterBar.swift
//  Divary
//
//  Created by 김나영 on 8/15/25.
//

import SwiftUI

struct StickerFooterBar: View {
    @Binding var footerBarType: DiaryFooterBarType
    
    var body: some View {
        VStack(spacing: 12) {
            // 상단 헤더 (닫기 버튼)
            HStack {
                Button(action: { footerBarType = .main }) {
                    Image(.iconamoonCloseThin)
                        .foregroundStyle(Color(.bWBlack))
                }
                Spacer()
            }
            // 메시지 영역
            VStack(spacing: 8) {
                Text("출시 예정!")
                    .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 18))
                    .foregroundStyle(Color(.bWBlack))
                Text("다채로운 스티커팩으로 일기장에 특별한 감성을 더해보세요.")
                    .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 14))
                    .foregroundStyle(Color(.bWBlack))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)        // ← 바 높이를 올리는 핵심
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.95))
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color(.G_100))
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
