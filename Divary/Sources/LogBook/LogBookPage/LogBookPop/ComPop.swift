//
//  ComPop.swift
//  Divary
//
//  Created by chohaeun on 8/6/25.
//

import SwiftUI
import Foundation

struct ComPop: View {
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
            VStack(alignment: .center, spacing: 16) {
                
                Text("기록이 모두 저장되었어요.\n멋진 로그가 완성되었네요!")
                    .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 16))
                    .foregroundStyle(Color.bw_black)
                    .multilineTextAlignment(.center)
                
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 22)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.3)
            .ignoresSafeArea()
        
        ComPop(
            onClose: { print("팝업 닫기") }
        )
        .padding()
    }
}
