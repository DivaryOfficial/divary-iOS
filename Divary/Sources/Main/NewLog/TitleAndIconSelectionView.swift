//
//  TitleAndIconSelectionView.swift
//  Divary
//
//  Created by chohaeun on 8/5/25.
//

// TitleAndIconSelectionView.swift

import SwiftUI

struct TitleAndIconSelectionView: View {
    @Bindable var viewModel: NewLogCreationViewModel
    var onComplete: (() -> Void)?
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)
    
    // 아이콘 목록 (plus 제외, ICON_TYPE 기준)
    let availableIcons: [IconType] = [
        .clownfish,        // 흰동가리
        .butterflyfish,    // 나비고기
        .octopus,          // 문어
        .cleanerWrasse,    // 청줄놀래기 (이미지: anchovy)
        .blackRockfish,    // 쏨배기 (이미지: blowfish)
        .seaHare,          // 군소 (이미지: clam)
        .pufferfish,       // 복어 (이미지: blowfish)
        .stripedBeakfish,  // 돌돔 (이미지: longhornCowfish)
        .nudibranch,       // 갯민숭달팽이 (이미지: seaSlug)
        .moonJellyfish,    // 보름달물해파리 (이미지: combJelly)
        .yellowtailScad,   // 줄전갱이 (이미지: dolphin)
        .mantisShrimp,     // 끄덕새우 (이미지: shrimp)
        .seaTurtle,        // 바다거북 (이미지: turtle)
        .starfish,         // 불가사리 (이미지: starfish)
        .redLionfish,      // 쏠배감펭 (이미지: lionfish)
        .seaUrchin         // 성게 (이미지: squid)
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            
            // 제목 입력
            VStack(alignment: .leading, spacing: 10) {
                
                Text("다이빙 로그 제목")
                    .font(Font.omyu.regular(size: 20))
                    .padding(.top, 30)
                
                TextField("제목을 입력해주세요", text: $viewModel.selectedTitle)
                    .font(Font.NanumSquareNeo.NanumSquareNeoRegular(size: 12))
                    .padding()
                    .background(Color.grayscale_g100)
                    .cornerRadius(8)
                    .disabled(viewModel.isLoading) // 로딩 중 비활성화
            }
            .padding(.horizontal)
            
            // 아이콘 선택
            VStack(alignment: .leading, spacing: 16) {
                Text("오늘의 바다 친구는?")
                    .font(Font.omyu.regular(size: 20))
                    .padding(.horizontal)
                
                LazyVGrid(columns: columns, spacing: 18) {
                    ForEach(availableIcons, id: \.self) { iconType in
                        Button(action: {
                            if !viewModel.isLoading { // 로딩 중이 아닐 때만 선택 가능
                                viewModel.selectedIcon = iconType
                            }
                        }) {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(viewModel.selectedIcon == iconType ? Color.primary_pastel_blue : Color.white)
                                        .frame(width: 60, height: 60)
                                    
                                    iconType.image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 60, height: 60)
                                }
                            }
                        }
                        .scaleEffect(viewModel.selectedIcon == iconType ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: viewModel.selectedIcon)
                        .disabled(viewModel.isLoading) // 로딩 중 비활성화
                    }
                }
                .padding(.horizontal)
            }
            
            // 하단 버튼들
            HStack(spacing: 16) {
                Button("이전으로") {
                    viewModel.currentStep = .calendar
                }
                .font(Font.omyu.regular(size: 16))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.grayscale_g100)
                .foregroundStyle(Color.grayscale_g500)
                .cornerRadius(8)
                .disabled(viewModel.isLoading) // 로딩 중 비활성화
                
                Button("작성하러 가기") {
                    // API 연동: 비동기 로그 생성
                    viewModel.createNewLog { logBaseId in
                        DispatchQueue.main.async {
                            if logBaseId != nil {
                                onComplete?()
                            }
                            // 에러 처리는 viewModel의 errorMessage로 처리됨
                        }
                    }
                }
                .font(Font.omyu.regular(size: 16))
                .frame(maxWidth: .infinity)
                .padding()
                .background(canProceed ? Color.primary_sea_blue : Color.grayscale_g100)
                .foregroundStyle(canProceed ? Color.white : Color.grayscale_g500)
                .cornerRadius(8)
                .disabled(!canProceed) // 조건 불만족 시 비활성화
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
    
    // 진행 가능 여부 계산
    private var canProceed: Bool {
        return !viewModel.selectedTitle.isEmpty &&
               viewModel.selectedIcon != nil &&
               !viewModel.isLoading
    }
}

#Preview {
    @Previewable @State var viewModel = NewLogCreationViewModel()
    TitleAndIconSelectionView(viewModel: viewModel)
}
