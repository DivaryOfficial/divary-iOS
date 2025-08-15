//
//  NewLogPop.swift
//  Divary
//
//  Created by chohaeun on 8/12/25.
//

import SwiftUI

struct NewLogPop: View {
    @Binding var isPresented: Bool
    @Binding var title: String
    var onCancel: () -> Void
    var onAddNewLog: (() -> Void)?
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
            
            VStack(spacing: 24) {
                // 제목
                Text("같은 날짜에 새로운 로그를\n추가하시겠어요?")
                    .font(Font.omyu.regular(size: 20))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                
                // 버튼들
                VStack(spacing: 12) {
                    
                    // 새 로그 추가 버튼
                    Button("새 로그 추가") {
                        onAddNewLog?()
                    }
                    .font(Font.omyu.regular(size: 16))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.primary_sea_blue)
                    .foregroundStyle(.white)
                    .cornerRadius(8)
                    
                    // 취소 버튼
                    Button("취소") {
                        onCancel()
                    }
                    .font(Font.omyu.regular(size: 16))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.grayscale_g200)
                    .foregroundStyle(Color.grayscale_g500)
                    .cornerRadius(8)
                }
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            .padding(.horizontal, 40)
        }
    }
}
