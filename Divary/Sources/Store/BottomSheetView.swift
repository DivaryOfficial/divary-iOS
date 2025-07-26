//
//  BottomSheetView.swift
//  Divary
//
//  Created by 바견규 on 7/26/25.
//

import SwiftUI

struct BottomSheetView<Content: View>: View {
    let content: Content
    let minHeight: CGFloat
    let medianHeight: CGFloat
    let maxHeight: CGFloat
    
    @GestureState private var dragOffset: CGFloat = 0
    @State private var currentHeight: CGFloat
    
    init(minHeight: CGFloat, medianHeight: CGFloat, maxHeight: CGFloat, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.minHeight = minHeight
        self.medianHeight = medianHeight
        self.maxHeight = maxHeight
        
        //초기 모달 위치는 medianHeight
        self.currentHeight = medianHeight
    }

    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 0) {
                // 드래그 핸들
                Capsule()
                    .frame(width: 40, height: 6)
                    .foregroundColor(.gray.opacity(0.5))
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                // 콘텐츠 영역
                if currentHeight > minHeight + 40 { // 콘텐츠가 보일 조건
                    VStack(spacing: 0) {
                        content
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top) // top 정렬
                }
            }
            .frame(height: currentHeight)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(20)
            .offset(y: dragOffset)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        let newHeight = currentHeight - value.translation.height
                        if newHeight <= maxHeight && newHeight >= minHeight {
                            state = value.translation.height
                        }
                    }
                    .onEnded { value in
                        let drag = value.translation.height
                        withAnimation(.spring()) {
                            if currentHeight == minHeight {
                                if drag < 0 {
                                    currentHeight = medianHeight
                                }
                            } else if currentHeight == medianHeight {
                                if drag < 0 {
                                    currentHeight = maxHeight
                                } else if drag > 0 {
                                    currentHeight = minHeight
                                }
                            } else if currentHeight == maxHeight {
                                if drag > 0 {
                                    currentHeight = medianHeight
                                }
                            }
                        }
                    }
            )
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    BottomSheetView(
        minHeight: UIScreen.main.bounds.height * 0.04,
        medianHeight: UIScreen.main.bounds.height * 0.5,
        maxHeight: UIScreen.main.bounds.height * 1.0
    ) {
        VStack(alignment: .leading, spacing: 16) {
            Text("온보딩 메시지나 텍스트 입력 뷰 등")
                .font(.headline)
            
            TextField("이름을 입력하세요", text: .constant(""))
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Text("추가 콘텐츠")
            Text("더 많은 내용")
        }
    }
}
