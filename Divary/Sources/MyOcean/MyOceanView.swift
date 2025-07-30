//
//  MyOceanView.swift
//  Divary
//
//  Created by 바견규 on 7/25/25.
//
import SwiftUI

struct CharacterView: View {
    @State private var viewModel: CharacterViewModel
    @State private var keyboardHeight: CGFloat = 0
    @Binding private var isPetEditingMode: Bool
    @State private var petDragOffset: CGSize = .zero
    @State private var petTempRotation: Angle = .zero
    var isStoreView: Bool
    
    var storeViewOffset: CGFloat {
        isStoreView ? 100 : 0
    }

    // 커스텀 init: 외부에서 편집 모드를 제어할 수 있도록 바인딩 추가
    init(
        viewModel: CharacterViewModel = CharacterViewModel(),
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
                    
                    Image(customization.background.rawValue)
                        .resizable()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    
                    let scale = min(geometry.size.width / 393, geometry.size.height / 852)
                    let x: CGFloat = 20 * scale
                    let y: CGFloat = (-110 + storeViewOffset) * scale
                    
                    // 캐릭터 장비들
                    characterEquipmentView(customization: customization, scale: scale, x: x, y: y)
                    
                    // 펫 뷰
                    petView(customization: customization, scale: scale, x: x, y: y, geometry: geometry)
                    
                    // 말풍선
                    speechBubbleView(customization: customization, scale: scale, x: x, y: y)
                    
                    // 온보딩 메시지
                    onboardingView(customization: customization, geometry: geometry)
                    
                    // 편집 모드 UI
                    if isPetEditingMode {
                        editingModeOverlay()
                    }
                    
                } else {
                    ProgressView("로딩 중...")
                        .task {
                            viewModel.loadFromJSON()
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
    }
    
    // MARK: - 캐릭터 장비 뷰
    @ViewBuilder
    private func characterEquipmentView(customization: CharacterCustomization, scale: CGFloat, x: CGFloat, y: CGFloat) -> some View {
        Image(customization.tank.rawValue)
            .scaleEffect(scale)
            .offset(x: (70 * scale) + x, y: (-10 * scale) + y)
        
        Image(customization.body.rawValue)
            .scaleEffect(scale)
            .offset(x: x, y: y)
        
        Image(customization.regulator.rawValue)
            .scaleEffect(scale)
            .offset(x: (-65 * scale) + x, y: (-30 * scale) + y)
        
        Image(customization.cheek.rawValue)
            .scaleEffect(scale)
            .offset(x: (-45 * scale) + x, y: (-40 * scale) + y)
        
        Image(customization.mask.rawValue)
            .scaleEffect(scale)
            .offset(x: (-28 * scale) + x, y: (-60 * scale) + y)
        
        Image(customization.pin.rawValue)
            .scaleEffect(scale)
            .offset(x: (68 * scale) + x, y: (85 * scale) + y)
    }
    
    // MARK: - 말풍선 뷰
    @ViewBuilder
    private func speechBubbleView(customization: CharacterCustomization, scale: CGFloat, x: CGFloat, y: CGFloat) -> some View {
        if isStoreView {
            customization.speechBubble.inputView(text: viewModel.speechTextBinding)
                .scaleEffect(scale)
                .offset(x: (-100 * scale) + x, y: (-170 * scale) + y)
        } else {
            customization.speechBubble.view(text: customization.speechText ?? "")
                .scaleEffect(scale)
                .offset(x: (-100 * scale) + x, y: (-170 * scale) + y)
        }
    }
    
    // MARK: - 온보딩 뷰
    @ViewBuilder
    private func onboardingView(customization: CharacterCustomization, geometry: GeometryProxy) -> some View {
        if customization.CharacterName == nil || customization.CharacterName?.isEmpty == true {
            HStack {
                Spacer()
                OnboardingMessageOverlay(userName: Binding(
                    get: { customization.CharacterName ?? "" },
                    set: { newValue in
                        viewModel.updateCharacterName(newValue)
                    }
                ))
                Spacer()
            }
            .offset(y: geometry.size.height * 0.2 - keyboardHeight / 2)
            .animation(.easeInOut(duration: 0.25), value: keyboardHeight)
        }
    }
    
    // MARK: - 펫 뷰
    @ViewBuilder
    private func petView(customization: CharacterCustomization, scale: CGFloat, x: CGFloat, y: CGFloat, geometry: GeometryProxy) -> some View {
        let baseFrameSize: CGFloat = 160
        let frameSize = baseFrameSize * scale  // 스케일 적용
        
        // 펫의 최종 위치 계산
        let finalX = (customization.pet.offset.width * scale) + x + petDragOffset.width
        let finalY = (customization.pet.offset.height * scale) + y + petDragOffset.height
        let finalRotation = customization.pet.rotation + petTempRotation
        
        ZStack {
            if isPetEditingMode {
                // 편집 모드
                Group {
                    // 선택 프레임
                    RoundedRectangle(cornerRadius: 8 * scale)  // 스케일 적용
                        .stroke(Color.primary_sea_blue, lineWidth: 2 * scale)  // 스케일 적용
                        .frame(width: frameSize + (10 * scale), height: frameSize + (10 * scale))  // 스케일 적용
                        .background(
                            RoundedRectangle(cornerRadius: 8 * scale)
                                .fill(Color.primary_sea_blue.opacity(0.1))
                        )
                    
                    // 펫 이미지
                    Image(customization.pet.type.rawValue)
                        .resizable()
                        .frame(width: frameSize, height: frameSize)  // 스케일이 적용된 frameSize 사용
                        .rotationEffect(finalRotation)
                    
                    // 모서리 핸들들
                    Group {
                        cornerHandle(at: CGSize(width: -frameSize/2 - (5 * scale), height: -frameSize/2 - (5 * scale)), scale: scale)
                        cornerHandle(at: CGSize(width: frameSize/2 + (5 * scale), height: -frameSize/2 - (5 * scale)), scale: scale)
                        cornerHandle(at: CGSize(width: -frameSize/2 - (5 * scale), height: frameSize/2 + (5 * scale)), scale: scale)
                        cornerHandle(at: CGSize(width: frameSize/2 + (5 * scale), height: frameSize/2 + (5 * scale)), scale: scale)
                    }
                    
                    // 회전 핸들
                    rotationHandle(frameSize: frameSize, scale: scale)
                }
                .offset(x: finalX, y: finalY)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            petDragOffset = value.translation
                        }
                        .onEnded { _ in
                            // 최종 위치 저장
                            viewModel.customization?.pet.offset.width += petDragOffset.width / scale
                            viewModel.customization?.pet.offset.height += petDragOffset.height / scale
                            petDragOffset = .zero
                            impactFeedback()
                        }
                )
                
            } else {
                // 일반 모드
                Image(customization.pet.type.rawValue)
                    .resizable()
                    .frame(width: frameSize, height: frameSize)  // 스케일이 적용된 frameSize 사용
                    .rotationEffect(customization.pet.rotation)
                    .offset(x: (customization.pet.offset.width * scale) + x,
                           y: (customization.pet.offset.height * scale) + y)
                    .onTapGesture(count: 2) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPetEditingMode = true
                        }
                        impactFeedback()
                    }
            }
        }
    }

    // MARK: - 모서리 핸들
    @ViewBuilder
    private func cornerHandle(at offset: CGSize, scale: CGFloat) -> some View {
        let handleSize = 16 * scale  // 스케일 적용
        
        Circle()
            .fill(Color.white)
            .stroke(Color.primary_sea_blue, lineWidth: 1 * scale)  // 스케일 적용
            .frame(width: handleSize, height: handleSize)
            .offset(offset)
    }

    // MARK: - 회전 핸들
    @ViewBuilder
    private func rotationHandle(frameSize: CGFloat, scale: CGFloat) -> some View {
        let handleOffset = CGSize(width: frameSize/2 + (25 * scale), height: -frameSize/2 - (25 * scale))  // 스케일 적용
        let handleSize = 24 * scale  // 스케일 적용
        
        Circle()
            .fill(Color.white)
            .stroke(Color.primary_sea_blue, lineWidth: 1 * scale)  // 스케일 적용
            .frame(width: handleSize, height: handleSize)
            .overlay(
                Image(systemName: "arrow.clockwise")
                    .foregroundStyle(Color.primary_sea_blue)
                    .font(.system(size: 10 * scale, weight: .semibold))  // 스케일 적용
            )
            .offset(handleOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let center = CGPoint.zero
                        let start = CGPoint(x: handleOffset.width, y: handleOffset.height)
                        let current = CGPoint(x: start.x + value.translation.width, y: start.y + value.translation.height)
                        
                        let startAngle = atan2(start.y - center.y, start.x - center.x)
                        let currentAngle = atan2(current.y - center.y, current.x - center.x)
                        
                        petTempRotation = .radians(Double(currentAngle - startAngle))
                    }
                    .onEnded { _ in
                        // 최종 회전 저장
                        viewModel.customization?.pet.rotation += petTempRotation
                        petTempRotation = .zero
                        impactFeedback()
                    }
            )
    }
    
    // MARK: - 편집 모드 오버레이
    @ViewBuilder
    private func editingModeOverlay() -> some View {
        VStack {
            
            Spacer()
            
            // 버튼들
            HStack {
                Spacer()
                
                VStack(spacing: 16) {
                    // 완료 버튼
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPetEditingMode = false
                        }
                        impactFeedback()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("완료")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.primary_sea_blue)
                        )
                    }
                    
                    // 리셋 버튼
                    Button(action: {
                        withAnimation(.spring(response: 0.5)) {
                            viewModel.customization?.pet.offset = .zero
                            viewModel.customization?.pet.rotation = .zero
                            petDragOffset = .zero
                            petTempRotation = .zero
                        }
                        impactFeedback()
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise.circle")
                            Text("리셋")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundStyle(Color.primary_sea_blue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .stroke(Color.primary_sea_blue, lineWidth: 1)
                        )
                    }
                }
                .padding(.trailing, 20)
            }
            .padding(.bottom, 50)
        }
    }
    
    // MARK: - 헬퍼 함수들
    
    // 햅틱 피드백
    private func impactFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

#Preview {
    @Previewable @State var isEditing = false
    return CharacterView(isPetEditingMode: $isEditing)
}
