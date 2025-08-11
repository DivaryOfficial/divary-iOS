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
    
    // 아이콘 목록 (plus 제외)
    let availableIcons: [IconType] = [
        .clownfish, .butterflyfish, .octopus, .anchovy,
        .seaSlug, .turtle, .blowfish, .dolphin,
        .longhornCowfish, .combJelly, .shrimp, .crab,
        .lionfish, .squid, .clam, .starfish
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
                            viewModel.selectedIcon = iconType
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
                .foregroundColor(Color.grayscale_g500)
                .cornerRadius(8)
                
                // "작성하러 가기" 버튼 수정
                Button(action: {
                    Task {
                        onComplete?()
                    }
                }) {
                    if viewModel.isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("생성 중...")
                        }
                    } else {
                        Text("작성하러 가기")
                    }
                }
                .disabled(viewModel.selectedTitle.isEmpty || viewModel.selectedIcon == nil || viewModel.isLoading)
                .font(Font.omyu.regular(size: 16))
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.selectedTitle.isEmpty || viewModel.selectedIcon == nil ? Color.grayscale_g100 : Color.primary_sea_blue)
                .foregroundColor(viewModel.selectedTitle.isEmpty || viewModel.selectedIcon == nil ? Color.grayscale_g500 : Color.white)
                .cornerRadius(8)
                .disabled(viewModel.selectedTitle.isEmpty || viewModel.selectedIcon == nil)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
}

#Preview {
    @Previewable @State var viewModel = NewLogCreationViewModel()
    TitleAndIconSelectionView(viewModel: viewModel)
}
