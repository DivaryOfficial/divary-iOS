//
//  rectangleSpeechBubble.swift
//  Divary
//
//  Created by 바견규 on 7/26/25.
//

import SwiftUI

struct RectangleSpeechBubble: View {
    var text: String
    
    var body: some View {
        Text(text)
            .font(Font.omyu.regular(size: 16))
            .foregroundColor(.bw_black)
            .padding(.horizontal, 12)
            .padding(.vertical, 18)
            .background(Color.white)
            .clipShape(RoundedCorner(radius: 8, corners: [.topLeft, .topRight, .bottomLeft]))
    }
}


// 입력 가능한 말풍선 (입력용)
struct RectangleSpeechBubbleInput: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField(text == "" ? "입력해주세요" : "", text: $text)
                .font(Font.omyu.regular(size: 16))
                .padding(.horizontal, 12)
                .padding(.vertical, 18)
                .foregroundColor(.bw_black)
        }
        .background(Color.white)
        .clipShape(RoundedCorner(radius: 8, corners: [.topLeft, .topRight, .bottomLeft]))
        .fixedSize(horizontal: true, vertical: false)
    }
}

// 프리뷰
#Preview {
    @Previewable @State var inputText = ""

    return VStack(spacing: 20) {
        HStack {
            Spacer()
            RectangleSpeechBubble(text: "다이브하러 가자!")
            Spacer()
        }
        HStack {
            Spacer()
            RectangleSpeechBubbleInput(text: $inputText)
            Spacer()
        }
        Spacer()
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}
