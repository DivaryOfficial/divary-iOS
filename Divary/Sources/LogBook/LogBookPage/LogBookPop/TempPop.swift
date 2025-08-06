//
//  TempPop.swift
//  Divary
//
//  Created by chohaeun on 8/6/25.
//

import SwiftUI
import Foundation

struct TempPop: View {
    let onTempSave: () -> Void
    let onDiscardChanges: () -> Void
    let onClose: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            // X 버튼 (팝업 밖에 위치)
            HStack {
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.bw_black)
                        .frame(width: 32, height: 32)

                }
            }
            .padding(.bottom, 12)
            
            // 실제 팝업 컨텐츠
            VStack(alignment: .center, spacing: 22) {
                Text("아직 작성되지 않은 내용이 있어요")
                .font(Font.omyu.regular(size: 24))
                .foregroundStyle(Color.bw_black)
            
            Text("저장하지 않으면 지금까지 입력한 내용이 사라질 수 있어요.")
                .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 12))
                .foregroundStyle(Color.grayscale_g400)
            
            // 임시 저장하고 나가기 버튼
            Button(action: onTempSave) {
                Text("임시 저장하고 나가기")
                    .font(Font.omyu.regular(size: 20))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.primary_sea_blue)
                    )
            }
            
            // 그냥 나가기 버튼
            Button(action: onDiscardChanges) {
                Text("그냥 나가기")
                    .font(Font.omyu.regular(size: 20))
                    .foregroundColor(.black)
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
        
        TempPop(
            onTempSave: { print("임시저장") },
            onDiscardChanges: { print("그냥 나가기") },
            onClose: { print("팝업 닫기") }
        )
        .padding()
    }
}
