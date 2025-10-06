//
//  StoreMainView.swift
//  Divary
//
//  Created by 바견규 on 7/26/25.
//

import SwiftUI

// 상단 탭 enum
enum StoreTab: String, CaseIterable {
    case myOcean = "나의 바다"
    case wardrobe = "옷장"
}

// 나의 바다 모달 탭
enum MyOceanTabType: String, CaseIterable {
    case oceanThema = "바다 테마"
    case buddyPet = "버디 펫"
}

// 옷장 모달 탭
enum wardrobeTabType: String, CaseIterable {
    case skin = "스킨"
    case diverItem = "다이버 아이템"
}

struct StoreMainView: View {
    // 모달 시트
    @State private var showSheet = true
    // 탭 바
    @State var selectedTab: StoreTab = .myOcean
    // 나의 바다 모달 탭
    @State private var MyOceanTab: MyOceanTabType = .oceanThema
    // 옷장 모달 탭
    @State private var wardrobeTab: wardrobeTabType = .skin
    
    // 펫 편집 모드 상태
    @State private var isPetEditingMode = false
    
    // 토스트 메시지 상태
    @State private var showToast = false
    
    @Bindable var viewModel: CharacterViewModel
    
    // 패드 기기 사이즈 조정
    @Environment(\.horizontalSizeClass) private var hSizeClass
    private var isPad: Bool { hSizeClass == .regular }
    
    var body: some View {
        ZStack {
            Color.white
            CharacterView(
                viewModel: viewModel,
                isStoreView: !isPetEditingMode,
                isPetEditingMode: $isPetEditingMode
            )
            
            VStack {
                VStack(spacing: 0) {
                    if showSheet && !isPetEditingMode {
                        StoreNavBar(showSheet: $showSheet, viewModel: viewModel)
                            .background(Color.white)
                            
                        TabSelector(selectedTab: $selectedTab)
                            .padding(.horizontal)
                            .background(Color.white)
                        
                        TooltipSection(
                            showToast: $showToast,
                            isPad: isPad,
                            showToastMessage: showToastMessage
                        )
                    }
                }
                
                if showSheet && !isPetEditingMode {
                    Group {
                        switch selectedTab {
                        case .myOcean:
                            BottomSheetView(
                                minHeight: UIScreen.main.bounds.height * 0.1,
                                medianHeight: UIScreen.main.bounds.height * 0.5,
                                maxHeight: UIScreen.main.bounds.height * 0.8
                            ) {
                                MyOceanStoreContent(
                                    selectedTab: $MyOceanTab,
                                    viewModel: viewModel,
                                    isPetEditingMode: $isPetEditingMode
                                )
                            }
                        case .wardrobe:
                            BottomSheetView(
                                minHeight: UIScreen.main.bounds.height * 0.1,
                                medianHeight: UIScreen.main.bounds.height * 0.5,
                                maxHeight: UIScreen.main.bounds.height * 0.8
                            ) {
                                WardrobeStoreContent(
                                    selectedTab: $wardrobeTab,
                                    viewModel: viewModel
                                )
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 토스트 메시지 표시 함수
    private func showToastMessage() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showToast = true
        }
        
        // 2초 후 자동으로 사라지게
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showToast = false
            }
        }
    }
}

// MARK: - 툴팁 섹션
struct TooltipSection: View {
    @Binding var showToast: Bool
    let isPad: Bool
    let showToastMessage: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            
            if showToast {
                Image("StoreTooltip")
                    .offset(x: isPad ? 0 : 30, y: 0)
                    .scaleEffect(isPad ? 1.3 : 1.0)
            }
            
            Button(action: showToastMessage) {
                Image("InfoCircle")
                    .resizable()
                    .foregroundStyle(Color.white)
                    .frame(width: isPad ? 32 : 24, height: isPad ? 32 : 24)
                    .padding(.horizontal, isPad ? 14 : 10)
                    .padding(.vertical, isPad ? 20 : 15)
            }
        }
    }
}

// MARK: - 나의 바다 스토어 컨텐츠
struct MyOceanStoreContent: View {
    @Binding var selectedTab: MyOceanTabType
    @Bindable var viewModel: CharacterViewModel
    @Binding var isPetEditingMode: Bool
    
    var body: some View {
        VStack {
            TopTabView(selectedTab: $selectedTab)
            
            switch selectedTab {
            case .oceanThema:
                OceanThemeStore(viewModel: viewModel)
            case .buddyPet:
                BuddyPetStore(
                    viewModel: viewModel,
                    isPetEditingMode: $isPetEditingMode
                )
            }
        }
    }
}

// MARK: - 옷장 스토어 컨텐츠
struct WardrobeStoreContent: View {
    @Binding var selectedTab: wardrobeTabType
    @Bindable var viewModel: CharacterViewModel
    
    var body: some View {
        VStack {
            TopTabView(selectedTab: $selectedTab)
            
            switch selectedTab {
            case .skin:
                SkinStore(viewModel: viewModel)
            case .diverItem:
                DiverItemStore(viewModel: viewModel)
            }
        }
    }
}
