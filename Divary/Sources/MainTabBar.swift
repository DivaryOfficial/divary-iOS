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
            // 조건부 렌더링으로 뷰 전환
            Group {
                switch container.selectedTab {
                case "기록":
                    MainWrapperView()
                        .gesture(
                            DragGesture(minimumDistance: 30, coordinateSpace: .local)
                                .onEnded { value in
                                    if value.translation.width < -50 {
                                        // 기록 탭에서만 캐릭터 뷰로 이동
                                        container.router.push(.CharacterViewWrapper)
                                    }
                                }
                        )
                case "챗봇":
                    ChatBotView()
                case "해양도감":
                    OceanCatalogView()
                case "My":
                    MyPageView()
                default:
                    MainWrapperView()
                }
            }
            
            // 탭 버튼들
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
            Spacer()
            Text("마이페이지 오픈 예정!")
                .font(Font.omyu.regular(size: 24))
                .foregroundStyle(Color.grayscale_g700)
            Text("구현 예정")
                .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 14))
                .foregroundStyle(Color.grayscale_g400)
                      
            Image("readyCharacter")
                .resizable()
                .frame(width: 200, height: 218)
                .scaledToFit()
            
            Spacer()
        }
    }
}

#Preview {
    MainTabbarView()
        .environmentObject(DIContainer(router: AppRouter()))
}
