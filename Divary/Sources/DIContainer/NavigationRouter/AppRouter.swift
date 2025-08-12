//
//  AppRouter.swift
//  SOAPFT
//
//  Created by 바견규 on 7/5/25.
//

import SwiftUI

enum Route: Hashable {
    case login
    case main
    case logBookMain(logBaseId: String)  
    case CharacterViewWrapper
    case Store(viewModel: CharacterViewModel)
}

class AppRouter: ObservableObject {
    @Published var path = NavigationPath()
    @Published var isLoggedIn = false
    
    func push(_ route: Route) {
        path.append(route)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func reset() {
        path = NavigationPath()
    }
    
    // 로그인 성공 시 호출할 메서드
    func navigateToMain() {
        path = NavigationPath() // 기존 네비게이션 스택 모두 제거
        isLoggedIn = true
        path.append(Route.main) // MainView로 이동
    }
    
    // 로그아웃 시 호출할 메서드
    func logout() {
        path = NavigationPath()
        isLoggedIn = false
        // LoginWrapperView가 루트이므로 별도 네비게이션 불필요
    }
}
