//
//  MyOceanView.swift
//  Divary
//
//  Created by 박견규 on 7/25/25.
//

import SwiftUI

struct CharacterViewWrapper: View {
    @Environment(\.diContainer) private var container
    @State private var viewModel: CharacterViewModel?
    
    var body: some View {
        Group {
            if let viewModel = viewModel {
                CharacterView(viewModel: viewModel)
//                    .toolbar(.hidden, for: .navigationBar)
                    .navigationBarBackButtonHidden(true)
            } else {
                LoadingOverlay(message: "로딩 중...", showBackground: true)
                    .task {
                        viewModel = CharacterViewModel(
                            avatarService: container.avatarService,
                            isMockData: false
                        )
                    }
            }
        }
    }
}

struct CharacterView: View {
    @State private var viewModel: CharacterViewModel
    @Environment(\.diContainer) private var container
    
    @State private var keyboardHeight: CGFloat = 0
    @Binding private var isPetEditingMode: Bool
    @State private var petDragOffset: CGSize = .zero
    @State private var petTempRotation: Angle = .zero
    @State private var showBuddySpeech = false // 버디 말풍선 상태
    
    // 부유 애니메이션을 위한 상태 변수들
    @State private var characterFloatingOffset: CGFloat = 0
    @State private var equipmentFloatingOffset: CGFloat = 0
    @State private var petFloatingOffset: CGFloat = 0
    @State private var speechBubbleFloatingOffset: CGFloat = 0
    
    var isStoreView: Bool
    
    var storeViewOffset: CGFloat {
        isStoreView ? 100 : 0
    }

    // 커스텀 init: 외부에서 편집 모드를 제어할 수 있도록 바인딩 추가
    init(
        viewModel: CharacterViewModel,
        isStoreView: Bool = false,
        isPetEditingMode: Binding<Bool> = .constant(false)
    ) {
        _viewModel = State(initialValue: viewModel)
        self.isStoreView = isStoreView
        self._isPetEditingMode = isPetEditingMode
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let customization = viewModel.customization {
                    
                    // 배경
                    if customization.background != .none {
                        Image(customization.background.rawValue)
                            .resizable()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    } else {
                        // 기본 바다 배경
                        LinearGradient(
                            colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                    
                    let scaleX = geometry.size.width / 393
                    let scaleY = geometry.size.height / 852
                    let scale = min(scaleX, scaleY)
                    let x: CGFloat = 20 * scaleX
                    let y: CGFloat = (-110 + storeViewOffset) * scaleY

                    // 상점 아이콘 (다른 컴포넌트와 동일한 방식)
                    if isStoreView == false && isPetEditingMode == false && customization.CharacterName != nil && customization.CharacterName?.isEmpty == false {
                        StoreButton(
                            scale: scale,
                            scaleX: scaleX,
                            scaleY: scaleY,
                            x: x,
                            y: y,
                            container: container,
                            viewModel: viewModel
                        )
                    }

                    // 캐릭터 장비들 (클릭 가능) - 부유 효과 적용
                    CharacterEquipmentView(
                        customization: customization,
                        scale: scale,
                        x: x,
                        y: y + equipmentFloatingOffset,
                        onTap: {
                            // 온보딩 완료된 경우에만
                            if customization.CharacterName != nil && !(customization.CharacterName?.isEmpty ?? true) {
                                impactFeedback()
                                showBuddySpeech = true
                            }
                        }
                    )
                    
                    // 펫 뷰 - 부유 효과 적용
                    PetView(
                        customization: customization,
                        scale: scale,
                        x: x,
                        y: y + petFloatingOffset, // 부유 효과를 y에 직접 적용
                        geometry: geometry,
                        isPetEditingMode: $isPetEditingMode,
                        petDragOffset: $petDragOffset,
                        petTempRotation: $petTempRotation,
                        viewModel: viewModel,
                        impactFeedback: impactFeedback
                    )
                    
                    // 말풍선 - 부유 효과 적용
                    SpeechBubbleView(
                        customization: customization,
                        scale: scale,
                        x: x,
                        y: y + speechBubbleFloatingOffset, // 부유 효과를 y에 직접 적용
                        isStoreView: isStoreView,
                        viewModel: viewModel
                    )
                    
                    // 온보딩 메시지
                    OnboardingView(
                        customization: customization,
                        geometry: geometry,
                        keyboardHeight: keyboardHeight,
                        viewModel: viewModel
                    )
                    
                    // 버디 말풍선
                    if showBuddySpeech {
                        BuddySpeechBubbleOverlay(
                            isVisible: $showBuddySpeech,
                            geometry: geometry,
                            keyboardHeight: keyboardHeight
                        )
                    }
                    
                    // 편집 모드 UI
                    if isPetEditingMode {
                        EditingModeOverlay(
                            isPetEditingMode: $isPetEditingMode,
                            petDragOffset: $petDragOffset,
                            petTempRotation: $petTempRotation,
                            viewModel: viewModel,
                            impactFeedback: impactFeedback
                        )
                    }
                    
                    
                    // 로딩 상태 표시
                    if viewModel.isLoading {
                        LoadingOverlay()
                    }
                    
                    // 에러 상태 표시
                    if let errorMessage = viewModel.errorMessage {
                        ErrorOverlay(
                            message: errorMessage,
                            viewModel: viewModel
                        )
                    }
                    
                } else {
                    LoadingOverlay(message: "아바타를 불러오는 중...", showBackground: true)
                        .task {
                            viewModel.loadAvatarFromServer()
                        }
                }
            }
        }
        .ignoresSafeArea()
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = keyboardFrame.height
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
        }
        .gesture(
            DragGesture(minimumDistance: -30, coordinateSpace: .local)
                .onEnded { value in
                    if value.translation.width > 50 {
                        // 라우터로 네비게이션
                        container.router.pop()
                    }
                }
        )
    }
    // MARK: - 헬퍼 함수들
    
    // 햅틱 피드백
    private func impactFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

// MARK: - 프리뷰
#Preview {
    CharacterViewWrapper()
}
