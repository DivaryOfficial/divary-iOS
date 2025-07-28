//
//  thoughtSpeechBubble.swift
//  Divary
//
//  Created by 바견규 on 7/26/25.
//

import SwiftUI

// 일반 말풍선 (생각풍선)
struct ThoughtSpeechBubbleView: View {
    var text: String
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Text(text)
                .font(Font.omyu.regular(size: 16))
                .foregroundStyle(Color.bw_black)
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
                .background(Color.white)
                .cornerRadius(50)
                .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
            
            VStack(spacing: 2) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 8, height: 8)
                    .offset(x: text.count < 5 ? -15 : -30, y: 20)
                Circle()
                    .fill(Color.white.opacity(0.7))
                    .frame(width: 6, height: 6)
                    .offset(x: text.count < 5 ? -8 : -20, y: 20)
            }
        }
    }
}

// 입력용 말풍선 (생각풍선)
struct ThoughtSpeechBubbleInputView: View {
    @Binding var text: String
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TextField(text.isEmpty ? "입력해주세요" : "", text: $text)
                .font(Font.omyu.regular(size: 16))
                .foregroundStyle(Color.bw_black)
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
                .background(Color.white)
                .cornerRadius(50)
                .fixedSize()
                .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
            
            VStack(spacing: 2) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 8, height: 8)
                    .offset(x: text.count < 5 ? -15 : -30, y: 20)
                Circle()
                    .fill(Color.white.opacity(0.7))
                    .frame(width: 6, height: 6)
                    .offset(x: text.count < 5 ? -8 : -20, y: 20)
            }
        }
    }
}

#Preview {
    @Previewable @State var inputText = ""
    
    return VStack(spacing: 20) {
        HStack {
            Spacer()
            ThoughtSpeechBubbleView(text: "다이브하러 가자!")
            Spacer()
        }
        HStack {
            Spacer()
            ThoughtSpeechBubbleInputView(text: $inputText)
            Spacer()
        }
        Spacer()
    }
    .background(Color.gray.opacity(0.2))
}
