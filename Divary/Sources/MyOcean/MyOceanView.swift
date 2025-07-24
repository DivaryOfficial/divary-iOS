//
//  MyOceanView.swift
//  Divary
//
//  Created by 바견규 on 7/25/25.
//
import SwiftUI

struct CharacterView: View {
    @StateObject private var viewModel = CharacterViewModel()
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let customization = viewModel.customization {
                    
                    Image(customization.background.rawValue)
                        .resizable()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    
                    // 화면 크기에 따른 스케일 계산 (아이폰 16 Pro 기준: 393x852)
                    let scale = min(geometry.size.width / 393, geometry.size.height / 852)
                    
                    // 원본 오프셋에 스케일을 적용하여 위치도 함께 조정
                    let x: CGFloat = 20 * scale
                    let y: CGFloat = -110 * scale
                    
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
                    
                    // Pet은 기존 offset과 rotation을 그대로 사용하되 스케일만 적용
                    Image(customization.pet.type.rawValue)
                        .scaleEffect(scale)
                        .rotationEffect(customization.pet.rotation)
                        .offset(
                            x: (customization.pet.offset.width * scale) + x,
                            y: (customization.pet.offset.height * scale) + y
                        )
                    
                    
                    // 온보딩 오버레이 (CharacterName이 nil이거나 빈 문자열일 때)
                    if customization.CharacterName == nil || customization.CharacterName?.isEmpty == true {
                        HStack {
                            Spacer() // 왼쪽 여백
                            
                            OnboardingMessageOverlay(userName: Binding(
                                get: { customization.CharacterName ?? "" },
                                set: { newValue in
                                    viewModel.updateCharacterName(newValue)
                                    print(viewModel.customization?.CharacterName ?? "")
                                }
                            ))
                            
                            Spacer() // 오른쪽 여백
                        }
                        .offset(y: geometry.size.height * 0.2 - keyboardHeight / 2) // 키보드 높이만큼 올리기
                        .animation(.easeInOut(duration: 0.25), value: keyboardHeight) // 애니메이션 추가
                    }
                    
                } else {
                    ProgressView("로딩 중...")
                        .onAppear {
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
}

#Preview {
    CharacterView()
}
