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
        
        // 초기 모달 위치는 medianHeight
        self._currentHeight = State(initialValue: medianHeight)
    }

    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 0) {
                // 드래그 핸들
                Capsule()
                    .frame(width: 40, height: 6)
                    .foregroundStyle(.gray.opacity(0.5))
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                // 콘텐츠 영역
                if currentHeight > minHeight + 40 { // 콘텐츠가 보일 조건
                    VStack(spacing: 0) {
                        content
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
            }
            .frame(height: currentHeight)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedCorner(radius: 12, corners: [.topLeft, .topRight]))
            // offset 제거 - 드래그 중에도 모달이 사라지지 않게
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation.height
                    }
                    .onEnded { value in
                        let dragDistance = value.translation.height
                        let dragThreshold: CGFloat = 100 // 드래그 임계값
                        
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            if currentHeight == minHeight {
                                // min에서는 위로만 이동 가능
                                if dragDistance < -dragThreshold {
                                    currentHeight = medianHeight
                                }
                            } else if currentHeight == medianHeight {
                                // med에서는 위/아래 모두 이동 가능
                                if dragDistance < -dragThreshold {
                                    currentHeight = maxHeight
                                } else if dragDistance > dragThreshold {
                                    currentHeight = minHeight
                                }
                            } else if currentHeight == maxHeight {
                                // max에서는 아래로만 이동 가능
                                if dragDistance > dragThreshold {
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


