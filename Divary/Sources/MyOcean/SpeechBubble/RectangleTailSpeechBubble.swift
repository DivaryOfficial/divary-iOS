//
//  rectangleTailSpeechBubble.swift
//  Divary
//
//  Created by 바견규 on 7/26/25.
//

import SwiftUI

struct RectangleTailSpeechBubble: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let cornerRadius: CGFloat = 12
        let tailWidth: CGFloat = 12
        let tailHeight: CGFloat = 10
        
        // 말풍선 본체
        path.addRoundedRect(in: CGRect(
            x: 0,
            y: 0,
            width: rect.width,
            height: rect.height - tailHeight
        ), cornerSize: CGSize(width: cornerRadius, height: cornerRadius))
        
        // 수평-수직 꺾인 꼬리: 오른쪽 하단
        let tailRight = rect.width < 90 ? rect.width * (3 / 4) : rect.width - 30
        let tailLeft = tailRight - tailWidth
        let tailTopY = rect.height - tailHeight
        
        path.move(to: CGPoint(x: tailLeft, y: tailTopY))                     // 수평 시작
        path.addLine(to: CGPoint(x: tailRight, y: tailTopY))                // 수평 오른쪽으로
        path.addLine(to: CGPoint(x: tailRight, y: rect.height))             // 수직 아래로
        path.closeSubpath()
        
        return path
    }
}


struct RectangleTailSpeechBubbleView: View {
    var text: String
    
    var body: some View {
        Text(text)
            .font(Font.omyu.regular(size: 16))
            .foregroundColor(.bw_black)
            .background(Color.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .padding(.bottom, 8)
            .background(
                RectangleTailSpeechBubble()
                    .fill(Color.white)
            )
            .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
}

// 입력용 꼬리 달린 말풍선
struct RectangleTailSpeechBubbleInputView: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField(text.isEmpty ? "입력해주세요" : "", text: $text)
                .font(Font.omyu.regular(size: 16))
                .foregroundColor(.bw_black)
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
                .padding(.bottom, 8)
                .background(
                    RectangleTailSpeechBubble()
                        .fill(Color.white)
                )
                .fixedSize()
                .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        }
    }
}



#Preview {
    @Previewable @State var inputText = ""

    return VStack(spacing: 20) {
        HStack {
            Spacer()
            RectangleTailSpeechBubbleView(text: "다이브하러 가자!")
            Spacer()
        }
        HStack {
            Spacer()
            RectangleTailSpeechBubbleInputView(text: $inputText)
            Spacer()
        }
        Spacer()
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}
