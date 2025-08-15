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
            }
            
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

// 캘린더 선택 뷰
struct NewLogCalendarView: View {
    @Bindable var viewModel: NewLogCreationViewModel
    @State private var tempMonth = Date()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("날짜선택")
                .font(Font.omyu.regular(size: 20))
                .padding(.leading, 16)
                .padding(.top, 22)
            
            // 캘린더 (기존 CalenderView 재사용)
            NewCalenderView(
                currentMonth: $tempMonth,
                selectedDate: $viewModel.selectedDate,
                startMonth: Calendar.current.date(byAdding: .month, value: -12, to: Date())!,
                endMonth: Calendar.current.date(byAdding: .month, value: 12, to: Date())!
            )
            .padding(.horizontal)
            
            // 완료 버튼
            Button("날짜 선택 완료") {
                viewModel.proceedToNextStep()
            }
            .font(Font.omyu.regular(size: 16))
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.primary_sea_blue)
            .foregroundStyle(.white)
            .cornerRadius(8)
            .padding(.horizontal)
            .padding(.bottom, 20)
            .disabled(viewModel.isLoading)
        }
    }
}

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


#Preview {
    @Previewable @State var viewModel = NewLogCreationViewModel()
    NewLogCreationView(viewModel: viewModel)
}
