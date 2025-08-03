//
//  AppRouter.swift
//  SOAPFT
//
//  Created by 바견규 on 7/5/25.
//

import SwiftUI

enum Route: Hashable {
    case login
}

class AppRouter: ObservableObject {
    @Published var path = NavigationPath()
    
    func push(_ route: Route) {
        path.append(route)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func reset() {
        path = NavigationPath()
    }
}
