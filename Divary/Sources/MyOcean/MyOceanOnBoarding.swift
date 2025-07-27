//
//  MyOceanOnBoarding.swift
//  Divary
//
//  Created by 바견규 on 7/25/25.
//

import SwiftUI

// MARK: - 온보딩 메시지 오버레이
struct OnboardingMessageOverlay: View {
    @State private var currentStep = 0
    @Binding var userName: String
    
    @State var nicknameString: String = ""
    @State private var showNameInput = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isCompleted = false
    
    let messages = [
        "나의 바다에 오신 것을 환영합니다!",
        "이곳은 바다 속 나만의 공간이에요\n나만의 감성으로 함께 채워보아요",
        "전 당신의 바다를 함께할 버디에요",
    ]
    
    var body: some View {
        if !isCompleted {
            ZStack {
                if showNameInput {
                    // 이름 입력 UI
                    nameInputSection
                } else {
                    // 온보딩 메시지 UI
                    onboardingMessageSection(fontSize: 20) // 고정 크기
                }
            }
        }
    }
    
    // MARK: - 온보딩 메시지 섹션
    private func onboardingMessageSection(fontSize: CGFloat) -> some View {
        SpeechBubble(
            text: messages[currentStep],
            fontSize: fontSize,
            backgroundColor: .white
        )
        .onTapGesture {
            nextStep()
        }
    }
    
    // MARK: - 이름 입력 섹션
    private var nameInputSection: some View {
        VStack(spacing: 0) {
            SpeechBubble(
                text: "근데.. 아직 제 이름이 없어요.\n멋진 이름 하나 지어주실래요?",
                fontSize: 20,
                backgroundColor: .white
            )
            
            VStack(spacing: 0) {
                TextField("이름을 입력해주세요", text: $nicknameString)
                    .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 12))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.bw_black)
                    .background(Color.grayscale_g100)
                    .cornerRadius(8)
                    .frame(width: 200)
                    .overlay(
                        Group {
                            if nicknameString.isEmpty {
                                Text("이름을 입력해주세요")
                                    .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 12))
                                    .foregroundColor(Color.grayscale_g400)
                                    .allowsHitTesting(false)
                            }
                        }
                    )
                
                Spacer().frame(height: 10)
                
                Button(action: { submitName() }) {
                    Text("작성 완료")
                        .font(Font.omyu.regular(size: 16))
                        .foregroundStyle(nicknameString.isEmpty ? Color.grayscale_g500 : Color.bw_white)
                        .frame(width: 200)
                        .padding(.vertical, 10)
                        .background(nicknameString.isEmpty ? Color.grayscale_g200 : Color.primary_sea_blue)
                        .cornerRadius(8)
                }
                .disabled(nicknameString.isEmpty)
                
                if showError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.system(size: 12))
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                        .transition(.opacity)
                }
            }
        }
        .padding(.horizontal, 39)
        .padding(.bottom, 22)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.bw_white)
        )
    }
    
    // MARK: - 액션 메서드들
    private func nextStep() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if currentStep < messages.count - 1 {
                currentStep += 1
            } else {
                showNameInput = true
            }
        }
    }
    
    private func submitName() {
        let trimmedName = nicknameString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 유효성 검사
        if trimmedName.isEmpty {
            showErrorMessage("이름을 입력해주세요!")
            return
        }
        
        if trimmedName.count > 20 {
            showErrorMessage("이름은 20자 이하로 입력해주세요!")
            return
        }
        
        // 특수문자 체크 (텍스트, 공백, 이모지만 허용)
        let hasInvalidCharacters = trimmedName.contains { char in
            !char.isLetter && !char.isWhitespace && !char.isEmoji
        }
        
        if hasInvalidCharacters {
            showErrorMessage("특수문자는 사용할 수 없습니다!")
            return
        }
        
        // 온보딩 완료
        userName = trimmedName
        withAnimation(.easeInOut(duration: 0.5)) {
            isCompleted = true
        }
        
        print("사용자 이름: \(trimmedName)")
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        withAnimation(.easeInOut(duration: 0.3)) {
            showError = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showError = false
            }
        }
    }
}

// MARK: - 말풍선 컴포넌트 (간단 버전)
struct SpeechBubble: View {
    let text: String
    let fontSize: CGFloat
    let backgroundColor: Color
    
    enum TailDirection {
        case bottomCenter
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text(text)
                .font(Font.omyu.regular(size: fontSize))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 44)
                .padding(.vertical, 22)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.bw_white)
        )
    }
}

// MARK: - 캐릭터뷰에 오버레이 적용
struct CharacterViewWithOnboarding: View {
    @State private var userName: String = ""
    
    var body: some View {
        ZStack {
            // 온보딩 메시지 오버레이
            OnboardingMessageOverlay(userName: $userName)
        }
        .background(Color.black)
    }
}

// MARK: - Character Extension for Emoji Detection
extension Character {
    var isEmoji: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        return scalar.properties.isEmoji && (scalar.value > 0x238C || unicodeScalars.count > 1)
    }
}

#Preview {
    CharacterViewWithOnboarding()
}
