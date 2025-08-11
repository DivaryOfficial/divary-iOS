//
//  DeletePopupView.swift - API 삭제 로직 추가
//  Divary
//
//  Created by 김나영 on 7/7/25.
//

import SwiftUI

struct DeletePopupView: View {
    @Binding var isPresented: Bool
    var deleteText: String
    var onConfirm: (() -> Void)? // 삭제 확인 콜백 추가
    
    func onDelete() {
        onConfirm?() // 실제 삭제 로직 호출
        isPresented = false
    }

    var body: some View {
        ZStack {
            Color.white.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }
            
            VStack {
                Text(deleteText)
                    .multilineTextAlignment(.center)
                    .padding(.top, 24)
                    .font(.omyu.regular(size: 24))
                
                HStack(spacing: 12) {
                    Button {
                        isPresented = false
                    } label: {
                        Text("취소")
                            .foregroundStyle(Color(.G_500))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.G_200))
                            .cornerRadius(8)
                            .font(.omyu.regular(size: 16))
                    }
                    
                    Button(action: onDelete) {
                        Text("삭제")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.seaBlue))
                            .foregroundStyle(.white)
                            .cornerRadius(8)
                            .font(.omyu.regular(size: 16))
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
    @Previewable @State var isPresented = true
    DeletePopupView(
        isPresented: $isPresented,
        deleteText: "지금 돌아가면 변경 내용이 모두 삭제됩니다.",
        onConfirm: { print("삭제 확인") }
    )
}
