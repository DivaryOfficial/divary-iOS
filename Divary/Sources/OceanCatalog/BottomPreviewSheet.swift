//
//  BottomPreviewSheet.swift
//  Divary
//
//  Created by 김나영 on 8/4/25.
//

import SwiftUI
import Kingfisher

struct BottomPreviewSheet: View {
    let creature: SeaCreatureDetail
    @Binding var isPresented: Bool
    let onDetailTapped: () -> Void

    @GestureState private var dragY: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let sheetH = max(0, geo.size.height * 0.45)
            
            // 로딩 감지
            let isPlaceholderDetail = [creature.size, creature.appearPeriod, creature.place].allSatisfy { $0 == "-" }
            
            ZStack(alignment: .bottom) {
                // 배경
                if isPresented {
                    Color.white.opacity(0.01)
//                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture {
                            withAnimation(.spring()) { isPresented = false }
                        }
                }
                // 시트 본체
                VStack(alignment: .leading, spacing: 8) {
                    // 핸들
                    Capsule().frame(width: 36, height: 5)
                        .foregroundStyle(Color(.grayscaleG300))
//                        .padding(.top, 4)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Text("\(creature.name)")
                        .font(.omyu.regular(size: 24))
                        .bold()
                    Text(creature.type)
                        .foregroundStyle(Color(.grayscaleG600))
                        .font(.NanumSquareNeo.NanumSquareNeoRegular(size: 14))

                    if isPlaceholderDetail {
                        // 로딩 UI
                        VStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        // 기존 본문
                        HStack(alignment: .center, spacing: 12) {
                            if let url = creature.imageUrls.first {
                                KFImage(url)
                                    .placeholder { ProgressView() }
                                    .retry(maxCount: 2, interval: .seconds(1))
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .id(url)
                            } else {
                                Color.gray.opacity(0.2)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                LabelledText(title: "크기", value: creature.size)
                                LabelledText(title: "출몰시기", value: creature.appearPeriod)
                                LabelledText(title: "서식", value: creature.place)
                            }
                        }
                    }

                    Button(action: onDetailTapped) {
                        Text("자세히보기")
                            .font(.omyu.regular(size: 20))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.seaBlue))
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                    }
                    .padding(.top, 8)
                }
                .padding()
                .frame(height: sheetH, alignment: .top)
                // 하단 safe area가 0이면 패딩을 줌
                .padding(.bottom, {
                    let bottomInset = (UIApplication.shared.connectedScenes
                        .compactMap { $0 as? UIWindowScene }
                        .flatMap { $0.windows }
                        .first { $0.isKeyWindow }?
                        .safeAreaInsets.bottom) ?? 0
                    return bottomInset == 0 ? 50 : 0
                }())
                .background(.white)
                .clipShape(RoundedCorners(tl: 12, tr: 12, bl: 0, br: 0))
                .shadow(radius: 8)
                .offset(y: isPresented ? max(0, dragY) : (sheetH + 80))
                .animation(.spring(response: 0.28, dampingFraction: 0.9), value: isPresented)
                .animation(.interactiveSpring(response: 0.25, dampingFraction: 0.85), value: dragY)
                .gesture( // 아래로 드래그 하여 화면 끄기
                    DragGesture()
                        .updating($dragY) { v, state, _ in
                            if v.translation.height > 0 { state = v.translation.height }
                        }
                        .onEnded { v in
                            let predicted = v.predictedEndTranslation.height
                            // 충분히 아래로 끌면 닫기
                            if predicted > sheetH * 0.33 || v.translation.height > sheetH * 0.25 {
                                withAnimation(.spring()) { isPresented = false }
                            }
                        }
                )
            }
            .allowsHitTesting(isPresented) // 닫혔을 땐 터치 통과
        }
        .transition(.move(edge: .bottom))
//        .ignoresSafeArea(edges: .bottom)
    }
}

private struct LabelledText: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.NanumSquareNeo.NanumSquareNeoRegular(size: 10))
                .foregroundStyle(Color(.grayscaleG600))
                .padding(.bottom, 0.5)
            Text(value)
                .font(.NanumSquareNeo.NanumSquareNeoRegular(size: 14))
                .multilineTextAlignment(.leading)
        }
        .padding(.bottom, 13)
    }
}
