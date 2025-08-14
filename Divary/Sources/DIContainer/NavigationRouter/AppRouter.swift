//
//  AppRouter.swift
//  SOAPFT
//
//  Created by 바견규 on 7/5/25.
//

import SwiftUI

enum Route: Hashable {
    case login
    case MainTabBar
    case main
    case logBookMain(logBaseId: String)
    case CharacterViewWrapper
    case Store(viewModel: CharacterViewModel)
    case notifications
    case locationSearch
    case oceanCatalog
    case oceanCreatureDetail(creature: SeaCreatureDetail)
}

class AppRouter: ObservableObject {
    @Published var path = NavigationPath()
    @Published var locationSearchText = ""
    
    var locationSearchBinding: Binding<String> {
        Binding(
            get: { self.locationSearchText },
            set: { self.locationSearchText = $0 }
        )
    }
    
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
