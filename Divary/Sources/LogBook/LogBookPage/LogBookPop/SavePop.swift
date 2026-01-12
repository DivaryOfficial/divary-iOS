//
//  SavePop.swift
//  Divary
//
//  Created by chohaeun on 8/6/25.
//

import SwiftUI
import Foundation

struct SavePop: View {
    let onCompleteSave: () -> Void
    let onTempSave: () -> Void
    let onClose: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            // X 버튼 (팝업 밖에 위치)
            HStack {
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Color.bw_black)
                        .frame(width: 32, height: 32)
                }
            }
            .padding(.bottom, 12)
            
            // 실제 팝업 컨텐츠
            VStack(alignment: .center, spacing: 20) {
                Text("어떤 방식으로 저장할까요?")
                    .font(Font.omyu.regular(size: 24))
                    .foregroundStyle(Color.bw_black)
                
                Text("작성 중인 내용이 일부 비어 있어요.\n 지금 끝내거나, 나중에 이어 쓸 수 있어요.")
                    .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 12))
                    .foregroundStyle(Color.grayscale_g400)
                    .multilineTextAlignment(.center)
                
                // 작성 완료하기 버튼
                Button(action: onCompleteSave) {
                    Text("작성 완료하기")
                        .font(Font.omyu.regular(size: 20))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.primary_sea_blue)
                        )
                }
                
                // 임시 저장하기 버튼
                Button(action: onTempSave) {
                    Text("임시 저장하기")
                        .font(Font.omyu.regular(size: 20))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.grayscale_g100)
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 22)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.3)
            .ignoresSafeArea()
        
        SavePop(
            onCompleteSave: { DebugLogger.log("작성 완료하기") },
            onTempSave: { DebugLogger.log("임시 저장하기") },
            onClose: { DebugLogger.log("팝업 닫기") }
        )
        .padding()
    }
}
