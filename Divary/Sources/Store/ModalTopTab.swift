//
//  ModalTopTab.swift
//  Divary
//
//  Created by 바견규 on 7/26/25.
//

import SwiftUI

// MARK: - 공용 TopTab 컴포넌트
struct TopTabView<TabType: Hashable & CaseIterable & RawRepresentable>: View where TabType.RawValue == String {
    @Binding var selectedTab: TabType
    @Namespace private var animation
    
    // 커스터마이징 옵션들
    let selectedColor: Color
    let unselectedColor: Color
    let underlineColor: Color
    let fontSize: CGFloat
    let showShadow: Bool
    let spacing: CGFloat
    
    init(
        selectedTab: Binding<TabType>,
        selectedColor: Color = Color.primary_sea_blue,
        unselectedColor: Color = Color.grayscale_g400,
        underlineColor: Color = Color.primary_sea_blue,
        fontSize: CGFloat = 20,
        showShadow: Bool = false,
        spacing: CGFloat = 10
    ) {
        self._selectedTab = selectedTab
        self.selectedColor = selectedColor
        self.unselectedColor = unselectedColor
        self.underlineColor = underlineColor
        self.fontSize = fontSize
        self.showShadow = showShadow
        self.spacing = spacing
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: spacing) {
                ForEach(Array(TabType.allCases), id: \.self) { tab in
                    Button(action: {
                        withAnimation(.easeInOut) {
                            selectedTab = tab
                        }
                    }) {
                        VStack() {
                            Text(tab.rawValue)
                                .font(Font.omyu.regular(size: fontSize))
                                .foregroundStyle(selectedTab == tab ? selectedColor : unselectedColor)
                                .frame(maxWidth: .infinity) // 버튼 내 텍스트를 가운데로
                        }
                        .frame(maxWidth: .infinity) // 버튼 자체도 균등 분할
                        .padding(10)
                    }
                    .padding(.horizontal, spacing/2)
                }
            }
            .if(showShadow) { view in
                view.shadow(color: Color.black.opacity(0.1), radius: 2, y: 1)
            }
            .padding(.horizontal, spacing)
            
            // 전체 밑줄과 하이라이트 언더라인을 겹치게 배치
            ZStack(alignment: .leading) {
                // 전체 회색 밑줄
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                
                // 선택된 탭의 하이라이트 언더라인
                HStack {
                    ForEach(Array(TabType.allCases), id: \.self) { tab in
                        if selectedTab == tab {
                            Capsule()
                                .fill(underlineColor)
                                .frame(height: 2)
                                .matchedGeometryEffect(id: "underline", in: animation)
                                .offset(y: -1)
                                .padding(.horizontal, spacing/2)
                        } else {
                            Color.clear
                                .frame(height: 3)
                        }
                    }
                }
                .padding(.horizontal, spacing)
            }
            .if(showShadow) { view in
                view.shadow(color: Color.black.opacity(0.3), radius: 2, y: 1)
            }
        }
    }
}

// MARK: - View Extension for Conditional Modifiers
extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - 사용 예시 1: Store 탭
enum StoreTabType: String, CaseIterable {
    case myOcean = "나의 바다"
    case wardrobe = "옷장"
}

// MARK: - 프리뷰 예시
struct TopTabPreviewView: View {
    @State private var storeTab: StoreTabType = .myOcean
    
    var body: some View {
        VStack() {
            // Store 탭 예시
            VStack {
                
                TopTabView(
                    selectedTab: $storeTab
                )
                .background(Color.white)
                
                Text("선택된 탭: \(storeTab.rawValue)")
                    .padding()
            }

        }
    }
}

#Preview {
    TopTabPreviewView()
}
