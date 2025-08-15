//
//  TitleEditPop.swift
//  Divary
//
//  Created by 개발자 on 8/11/25.
//

import SwiftUI

struct TitleEditPopup: View {
    @Binding var isPresented: Bool
    @Binding var title: String
    var onSave: () -> Void
    var onCancel: () -> Void
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
            
            VStack(spacing: 24) {
                // 제목
                Text("로그북 제목 수정")
                    .font(Font.omyu.regular(size: 20))
                    .foregroundStyle(.black)
                
                // 텍스트 입력 필드
                VStack(alignment: .leading, spacing: 8) {
                    Text("제목")
                        .font(Font.omyu.regular(size: 16))
                        .foregroundStyle(Color.grayscale_g600)
                    
                    TextField("로그북 제목을 입력하세요", text: $title)
                        .font(Font.omyu.regular(size: 16))
                        .padding(12)
                        .background(Color.grayscale_g100)
                        .cornerRadius(8)
                        .focused($isTextFieldFocused)
                        .onSubmit {
                            onSave()
                        }
                }
                
                // 버튼들
                HStack(spacing: 12) {
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
                    
                    // 저장 버튼
                    Button("저장") {
                        onSave()
                    }
                    .font(Font.omyu.regular(size: 16))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                               Color.grayscale_g300 : Color.primary_sea_blue)
                    .foregroundStyle(.white)
                    .cornerRadius(8)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            .padding(.horizontal, 40)
        }
//        .task {
        .task {
            // 팝업이 나타날 때 자동으로 키보드 포커스
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isTextFieldFocused = true
            }
        }
    }
}

