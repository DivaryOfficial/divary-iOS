//
//  MainTabBar.swift
//  Divary
//
//  Created by 바견규 on 8/13/25.
//

import SwiftUI

struct MainTabbarView: View {
    @EnvironmentObject var container: DIContainer

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $container.selectedTab) {
                MainWrapperView()
                    .tag("기록")
                
                ChatBotView()
                    .tag("챗봇")
                
                OceanCatalogView()
                    .tag("해양도감")
                
                // 마이페이지 뷰 추가 필요
                MyPageView() // 또는 적절한 뷰
                    .tag("My")
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            HStack {
                tabButton(title: "기록", selectedImage: "tabBarLogSelected", nonSelectedImage: "tabBarLogUnSelected")
                tabButton(title: "챗봇", selectedImage: "tabBarChatBotSelected", nonSelectedImage: "tabBarChatBotUnSelected")
                tabButton(title: "해양도감", selectedImage: "tabBarOceanCatalogSelected", nonSelectedImage: "tabBarOceanCatalogUnSelected")
                tabButton(title: "My", selectedImage: "tabBarMySelected", nonSelectedImage: "tabBarMyUnSelected")
            }
            .padding()
            .background(Color.white)
        }
    }
    
    @ViewBuilder
    private func tabButton(title: String, selectedImage: String, nonSelectedImage: String) -> some View {
        Button {
            container.selectedTab = title
            print("탭 선택됨: \(title)")
        } label: {
            VStack(spacing: 4) {
                Image(container.selectedTab == title ? selectedImage : nonSelectedImage)
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(container.selectedTab == title ? Color.primary_sea_blue : Color.grayscale_g600)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

// 임시 마이페이지 뷰 (실제 구현 필요)
struct MyPageView: View {
    var body: some View {
        VStack {
            Text("마이페이지")
                .font(.title)
            Text("구현 예정")
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    MainTabbarView()
}
