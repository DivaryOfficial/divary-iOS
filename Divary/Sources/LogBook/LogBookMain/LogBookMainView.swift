//
//  LogBookMain.swift
//  Divary
//
//  Created by 바견규 on 7/8/25.
//

import SwiftUI

//상단 탭 enum
enum DiveLogTab: String, CaseIterable {
    case logbook = "로그북"
    case diary = "일기"
}

struct LogBookMainView: View {
    @State var selectedTab: DiveLogTab = .logbook
    
    var body: some View {
        VStack(spacing: 0) {
            LogBookNavBar()
            TabSelector(selectedTab: $selectedTab)
                .padding(.horizontal)
            
            // 선택된 탭에 따라 다른 뷰 표시
            Group {
                switch selectedTab {
                case .logbook:
                    LogBookPageView(diveLogData: LogBookPageMock)
                case .diary:
                    ContentView() // 원하는 일기 뷰로 교체
                }
            }
            .transition(.opacity) // 전환 애니메이션 (선택)
            .animation(.easeInOut, value: selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    LogBookMainView()
}
