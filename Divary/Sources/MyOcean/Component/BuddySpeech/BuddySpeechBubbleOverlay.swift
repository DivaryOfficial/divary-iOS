//
//  BuddySpeechBubbleOverlay.swift
//  Divary
//
//  Created by 바견규 on 8/22/25.
//

import SwiftUI


// MARK: - 버디 말풍선 메시지 배열
struct BuddyMessages {
    static let messages = [
        "오늘도 바다가 참 예쁘네요.",
        "파도가 잔잔해서 기분이 좋아요.",
        "맑은 물결이 반짝반짝 빛나요.",
        "바닷속 공기가 상쾌하네요.",
        "물방울이 톡톡 올라오네요.",
        "바다 친구들이 인사하러 올 것 같아요.",
        "깊은 바다가 참 편안하죠.",
        "햇살이 물결에 비쳐서 반짝여요.",
        "바다 속이 오늘따라 더 평화로워요.",
        "바닷속 여행이 즐거우시길 바라요.",
        "시원한 물결이 참 기분 좋네요.",
        "고요한 파도 소리가 들리는 것 같아요.",
        "바람이 불어와 시원하네요.",
        "바닷속 풍경이 눈부시게 아름다워요.",
        "오늘은 바다가 유난히 맑네요.",
        "물결 따라 기분도 가벼워져요.",
        "파도가 반짝이며 춤추고 있어요.",
        "잔잔한 바다가 마음을 편안하게 해요.",
        "깊은 곳에서도 햇살이 따뜻하네요.",
        "오늘 바다는 참 고요하고 예쁘네요."
    ]
    
    static func randomMessage() -> String {
        return messages.randomElement() ?? messages[0]
    }
}

// MARK: - 버디 말풍선 오버레이
struct BuddySpeechBubbleOverlay: View {
    @Binding var isVisible: Bool
    @State private var currentMessage = ""
    @State private var opacity: Double = 0
    let geometry: GeometryProxy
    let keyboardHeight: CGFloat
    
    var body: some View {
        if isVisible {
            HStack {
                Spacer()
                SpeechBubble(
                    text: currentMessage,
                    fontSize: 20,
                    backgroundColor: .white
                )
                .onTapGesture {
                    // 말풍선 클릭 시 자연스럽게 사라짐
                    withAnimation(.easeInOut(duration: 0.5)) {
                        opacity = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isVisible = false
                    }
                }
                Spacer()
            }
            .opacity(opacity)
            .offset(y: geometry.size.height * 0.2 - keyboardHeight / 2)
            .animation(.easeInOut(duration: 0.25), value: keyboardHeight)
            .task {
                // 새 메시지 설정
                currentMessage = BuddyMessages.randomMessage()
                
                // 서서히 나타남
                withAnimation(.easeInOut(duration: 0.4)) {
                    opacity = 1
                }
                
                // 2초 후 서서히 사라짐
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        opacity = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        isVisible = false
                    }
                }
            }
        }
    }
}

// MARK: - 버튼 효과 없는 커스텀 스타일
struct NoEffectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
