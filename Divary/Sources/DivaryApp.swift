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
                if container.selectedTab == "기록" {
                    MainTabbarView()
                        .ignoresSafeArea(.all, edges: .top)
                } else {
                    MainTabbarView()
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .login:
                    LoginWrapperView()
                case .main:
                    MainView()
                        .navigationBarBackButtonHidden(true)
                case .logBookMain(let logBaseId):
                    LogBookMainView(logBaseId: logBaseId)
                case .CharacterViewWrapper:
                    CharacterViewWrapper()
                case .Store(let viewModel):
                    StoreMainView(viewModel: viewModel)
                        .navigationBarBackButtonHidden(true)
                case .notifications:
                    NotificationView()
                case .MainTabBar:
                    MainTabbarView()
                }
            }
            .environmentObject(container)
            .environment(\.diContainer, container)
        }
    }
}
