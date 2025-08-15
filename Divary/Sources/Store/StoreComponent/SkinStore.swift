//
//  SkinStore.swift
//  Divary
//
//  Created by 바견규 on 8/13/25.
//

import SwiftUI

struct SkinStore: View {
    @Bindable var viewModel: CharacterViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                // 바디 색상
                BodyColorSection(viewModel: viewModel)
                
                // 볼터치 색상
                CheekColorSection(viewModel: viewModel)
                
                // 말풍선
                SpeechBubbleSection(viewModel: viewModel)
            }
            .padding(.top)
            .padding(.bottom, 50)
            .padding(.horizontal, 12) // 제목들만 여백 적용
        }
    }
}

// MARK: - 바디 색상 섹션
struct BodyColorSection: View {
    @Bindable var viewModel: CharacterViewModel
    
    private func colorForBody(_ type: CharacterBodyType) -> Color {
        switch type {
        case .ivory: return Color(hex: "#FFFDF6")
        case .cream: return Color(hex: "#FFF6D2")
        case .pink: return Color(hex: "#FFE9E9")
        case .brown: return Color(hex: "#AF9685")
        case .gray: return Color(hex: "#7B8184")
        default: return .clear
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("바디 색상")
                .font(Font.omyu.regular(size: 20))
                .foregroundStyle(Color.bw_black)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(CharacterBodyType.allCases.filter { $0 != .none }, id: \.self) { type in
                        let isSelected = viewModel.customization?.body == type
                        Circle()
                            .fill(colorForBody(type))
                            .frame(width: 54, height: 54)
                            .overlay(
                                ZStack {
                                    Circle()
                                        .stroke(isSelected ? Color.primary_sea_blue : Color.grayscale_g300, lineWidth: 1)
                                        .padding(1)
                                    
                                    if isSelected {
                                        Image("humbleicons_check")
                                            .resizable()
                                            .scaledToFit()
                                            .scaleEffect(0.4)
                                            .foregroundStyle(Color.primary_sea_blue)
                                    }
                                }
                            )
                            .onTapGesture {
                                viewModel.customization = viewModel.customization?.copy(body: type)
                            }
                    }
                }
                .padding(.horizontal, 12) // 첫째/마지막 아이템이 화면 끝에서 12px 떨어지도록
            }
            .padding(.horizontal, -12) // ScrollView를 화면 끝까지 확장
        }
    }
}

// MARK: - 볼터치 색상 섹션
struct CheekColorSection: View {
    @Bindable var viewModel: CharacterViewModel
    
    private func colorForCheek(_ type: CheekType) -> Color {
        switch type {
        case .peach: return Color(hex: "#FFD4D4")
        case .salmon: return Color(hex: "#FFD4C7")
        case .orange: return Color(hex: "#FFAD94")
        case .coral: return Color(hex: "#FFA6A6")
        case .pink: return Color(hex: "#FFC2FF")
        default: return .clear
        }
    }
    
    @ViewBuilder
    private func cheekItemView(for type: CheekType, isSelected: Bool) -> some View {
        if type == .none {
            // none 버튼 - 고정 크기
            let imageName = isSelected ? "noneClicked" : "noneDefault"
            
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 54, height: 54)
        } else {
            // 기존 색상 원형 버튼
            Circle()
                .fill(colorForCheek(type))
                .frame(width: 54, height: 54)
                .overlay(
                    ZStack {
                        Circle()
                            .stroke(isSelected ? Color.primary_sea_blue : Color.grayscale_g300, lineWidth: 1)
                            .padding(1)
                        
                        if isSelected {
                            Image("humbleicons_check")
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(0.4)
                                .foregroundStyle(Color.primary_sea_blue)
                        }
                    }
                )
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("볼터치 색상")
                .font(Font.omyu.regular(size: 20))
                .foregroundStyle(Color.bw_black)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(CheekType.allCases, id: \.self) { type in
                        let isSelected = viewModel.customization?.cheek == type
                        cheekItemView(for: type, isSelected: isSelected)
                            .onTapGesture {
                                viewModel.customization = viewModel.customization?.copy(cheek: type)
                            }
                    }
                }
                .padding(.horizontal, 12) // 첫째/마지막 아이템이 화면 끝에서 12px 떨어지도록
            }
            .padding(.horizontal, -12) // ScrollView를 화면 끝까지 확장
        }
    }
}

// MARK: - 말풍선 섹션
struct SpeechBubbleSection: View {
    @Bindable var viewModel: CharacterViewModel
    
    @ViewBuilder
    private func speechBubbleItemView(for type: SpeechBubbleType, isSelected: Bool) -> some View {
        let imageName = isSelected ? type.clickedImageName : type.defaultImageName
        
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 54)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("말풍선")
                .font(Font.omyu.regular(size: 20))
                .foregroundStyle(Color.bw_black)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(SpeechBubbleType.allCases, id: \.self) { type in
                        let isSelected = viewModel.customization?.speechBubble == type
                        speechBubbleItemView(for: type, isSelected: isSelected)
                            .onTapGesture {
                                viewModel.customization = viewModel.customization?.copy(speechBubble: type)
                                viewModel.speechTextBinding.wrappedValue = ""
                            }
                    }
                }
                .padding(.horizontal, 12) // 첫째/마지막 아이템이 화면 끝에서 12px 떨어지도록
            }
            .padding(.horizontal, -12) // ScrollView를 화면 끝까지 확장
        }
    }
}
