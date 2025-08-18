//
//  ExistingPoP.swift
//  Divary
//
//  Created by chohaeun on 8/18/25.
//

import SwiftUI

// 기존 로그 확인 뷰
struct ExistingLogConfirmView: View {
    @Bindable var viewModel: NewLogCreationViewModel
    var onNavigateToExisting: ((String) -> Void)?
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                Text("선택한 날짜에 로그가 존재합니다.")
                    .font(Font.omyu.regular(size: 24))
                    .multilineTextAlignment(.center)
                
                Text("기존 로그로 이동하시겠습니까?")
                    .font(Font.omyu.regular(size: 24))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            // 버튼들
            VStack(spacing: 12) {
                Button("기존 로그 이동") {
                    if let existingLogId = viewModel.getExistingLogBaseId() {
                        onNavigateToExisting?(existingLogId)
                    }
                }
                .font(Font.omyu.regular(size: 20))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primary_sea_blue)
                .foregroundStyle(.white)
                .cornerRadius(8)
                
                Button("날짜 다시 선택") {
                    viewModel.currentStep = .calendar
                }
                .font(Font.omyu.regular(size: 20))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.grayscale_g100)
                .foregroundStyle(Color.grayscale_g500)
                .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
}
