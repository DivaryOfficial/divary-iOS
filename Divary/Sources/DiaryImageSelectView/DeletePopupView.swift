//
//  DeletePopupView.swift
//  Divary
//
//  Created by 김나영 on 7/7/25.
//

import SwiftUI

struct DeletePopupView: View {
    var onCancel: () -> Void
    var onDelete: () -> Void

    var body: some View {
        ZStack {
            Color.white.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("사진을 삭제할까요?")
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
    DeletePopupView(onCancel: {
        print("취소 버튼")
    },
    onDelete: {
        print("삭제 버튼")
    })
}
