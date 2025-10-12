//
//  InteractivePopGesture.swift
//  Divary
//
//  Created by 김나영 on 9/25/25.
//

import Foundation
import SwiftUI

/// NavigationStack 아래의 UINavigationController를 찾아
/// interactivePopGesture를 활성화하고 delegate를 연결한다.
struct InteractivePopConfigurator: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        // 다음 런루프에서 네비게이션 컨트롤러를 안전하게 획득
        DispatchQueue.main.async {
            if let nav = vc.navigationController {
                context.coordinator.nav = nav
                nav.interactivePopGestureRecognizer?.isEnabled = true
                nav.interactivePopGestureRecognizer?.delegate = context.coordinator
                // 기본 네비바를 숨기는 앱이면 아래 라인도 상황에 맞게 유지
                // nav.isNavigationBarHidden = true
            }
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        weak var nav: UINavigationController?

        /// 루트에서 스와이프 시작을 막아야(깜빡임/무반응 방지)
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            (nav?.viewControllers.count ?? 0) > 1
        }
    }
}

extension View {
    /// 좌측 에지 스와이프(Interactive Pop)를 전역 활성화
    func enableInteractivePopGesture() -> some View {
        // background로 심어서 뷰 계층 어디서든 네비게이션 컨트롤러를 찾게 함
        self.background(InteractivePopConfigurator())
    }
}
