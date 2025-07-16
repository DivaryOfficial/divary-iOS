//
//  DeletePopupView.swift
//  Divary
//
//  Created by 김나영 on 7/7/25.
//

import SwiftUI

struct DeletePopupView: View {
    var deleteText: String
    
    var onCancel: () -> Void = {
        print("취소 클릭")
    }
    var onDelete: () -> Void = {
        print("삭제 클릭")
    }

    var body: some View {
        ZStack {
            Color.white.opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Text(deleteText)
                    .font(.body)
                    .padding(.top, 24)
                
                HStack(spacing: 12) {
                    Button(action: onCancel) {
                        Text("취소")
                            .foregroundColor(Color(.G_500))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.G_200))
                            .cornerRadius(8)
                    }
                    
                    Button(action: onDelete) {
                        Text("삭제")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.seaBlue))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.G_300), lineWidth: 1)
            )
            .padding(.horizontal, 40)
        }
    }
}

#Preview {
    DeletePopupView(deleteText: "지금 돌아가면 변경 내용이 모두 삭제됩니다.")
}
