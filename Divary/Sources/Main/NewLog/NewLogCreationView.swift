//
//  NewLogMain.swift
//  Divary
//
//  Created by chohaeun on 8/5/25.
//

// NewLogCreationView.swift - API 연동 버전

import SwiftUI

struct NewLogCreationView: View {
    @Bindable var viewModel: NewLogCreationViewModel
    var onNavigateToExistingLog: ((String) -> Void)?
    var onCreateNewLog: (() -> Void)?
    
    var body: some View {
        ZStack {
            Color.white.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    viewModel.resetData()
                }
            
            // 중앙 정렬을 위한 VStack
            VStack {
                Spacer() // 상단 여백
                
                // X 버튼 - 흰색 박스 바깥에 위치
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.resetData()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundStyle(.black)
                            .padding(12)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8) // X 버튼과 박스 사이 간격
                
                // 메인 콘텐츠 박스
                VStack(spacing: 0) {
                    // 현재 단계에 따른 뷰
                    Group {
                        switch viewModel.currentStep {
                        case .calendar:
                            NewLogCalendarView(viewModel: viewModel)
                        case .existingLogConfirm:
                            ExistingLogConfirmView(
                                viewModel: viewModel,
                                onNavigateToExisting: { logBaseId in
                                    onNavigateToExistingLog?(logBaseId)
                                }
                            )
                        case .titleAndIcon:
                            TitleAndIconSelectionView(
                                viewModel: viewModel,
                                onComplete: {
                                    onCreateNewLog?()
                                }
                            )
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(.horizontal) // 좌우 패딩만 적용
                
                Spacer() // 하단 여백
            }.padding(.horizontal)
            
            // 로딩 인디케이터
            if viewModel.isLoading {
//                LoadingOverlayTemp(text: "로딩 중...")
                LoadingOverlay(message: "로딩 중...")
            }
        }
        .alert("오류", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("확인") {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

#Preview {
    @Previewable @State var viewModel = NewLogCreationViewModel()
    NewLogCreationView(viewModel: viewModel)
}
