//
//  FrameSelectBar.swift
//  Divary
//
//  Created by 김나영 on 8/7/25.
//

import SwiftUI

struct FrameSelectBar: View {
    @Binding var selectedFrame: FrameColor
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(FrameColor.allCases, id: \.self) { type in
                    Button (action: {
                        selectedFrame = type
                    }) {
                        frameSelection(for: type)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical)
                }
            }
        }
        .background(Color(.G_100))
    }
    
    // MARK: - 개별 프레임 버튼 생성
    @ViewBuilder
    private func frameSelection(for type: FrameColor) -> some View {
        if type == .origin { // 없음 버튼
            ZStack {
                Rectangle()
                    .frame(width: 70, height: 87)
                    .foregroundStyle(Color(.G_300))
                Text("없음")
                    .font(.NanumSquareNeo.NanumSquareNeoBold(size: 12))
                    .foregroundStyle(Color(.black))
            }
        }
        else { // 색상 버튼
            ZStack {
                Rectangle()
                    .fill(type.frameColor)
                    .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
                
                VStack {
                    RoundedRectangle(cornerRadius: 1.6)
                        .fill(Color.white)
                        .cornerRadius(1.6)
                        .aspectRatio(1, contentMode: .fit)
                    Spacer()
                        .frame(height: 20)
                }
                .padding(.horizontal, 3)
                .padding(.top, 3)
            }
            .frame(width: 70, height: 85)
        }
    }
}

struct StatefulPreviewWrapper<Value: Equatable, Content: View>: View {
    @State var value: Value
    let content: (Binding<Value>) -> Content
    
    init(_ value: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        self._value = State(initialValue: value)
        self.content = content
    }
    
    var body: some View {
        content($value)
    }
}

#Preview {
    StatefulPreviewWrapper(FrameColor.pastelBlue) { selected in
        FrameSelectBar(selectedFrame: selected)
    }
}


//#Preview {
//    @State var selectedFrame: FrameColor = .pastelBlue
//    
//    FrameSelectBar(selectedFrame: selectedFrame)
//}
