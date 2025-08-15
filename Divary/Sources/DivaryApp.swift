import SwiftUI

@main
struct DivaryApp: App {
    @StateObject private var router = AppRouter()
    @StateObject private var container: DIContainer
    
    init() {
        let appRouter = AppRouter()
        self._router = StateObject(wrappedValue: appRouter)
        self._container = StateObject(wrappedValue: DIContainer(router: appRouter))
    }
    
    var body: some Scene {
        WindowGroup {

            NavigationStack(path: $router.path) {
                LoginWrapperView()
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .login:
                            LoginWrapperView()
                        case .main:
                            MainView()
                        case .logBookMain(let logBaseId):
                            LogBookMainView(logBaseId: logBaseId)
                                .navigationBarBackButtonHidden(true)
                        case .CharacterViewWrapper:
                            CharacterViewWrapper()
                        case .Store(let viewModel):
                            StoreMainView(viewModel: viewModel)
                                .navigationBarBackButtonHidden(true)
                        case .notifications:
                            NotificationView()
                        case .MainTabBar:
                            MainTabbarView()
                                .navigationBarBackButtonHidden(true)
                        case .chatBot:
                            ChatBotView()
                                .navigationBarBackButtonHidden(true)
                        case .locationSearch:
                            LocationSearchView(
                                       currentValue: container.router.locationSearchText,
                                       placeholder: "ë‹¤ì´ë¹™ ìŠ¤íŒŸ ê²€ìƒ‰",
                                       onLocationSelected: { selectedLocation in
                                           // ì„ íƒëœ ìœ„ì¹˜ë¥¼ AppRouterì— ì €ìž¥
                                           container.router.locationSearchText = selectedLocation
                                       }
                                   )
                                   .environment(\.diContainer, container)
                            .navigationBarBackButtonHidden(true)
                        }
                    }
            }
            .navigationViewStyle(.stack)
            .environmentObject(container)
            .environment(\.diContainer, container)
        }
    }
}
