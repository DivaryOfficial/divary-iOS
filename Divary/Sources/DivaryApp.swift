import SwiftUI

@main
struct DivaryApp: App {
    @StateObject private var router = AppRouter()
    private var container: DIContainer
    
    init() {
        // 동일한 router 인스턴스 사용
        let appRouter = AppRouter()
        self._router = StateObject(wrappedValue: appRouter)
        self.container = DIContainer(router: appRouter)
    }
    
    var body: some Scene {
        WindowGroup {
            OceanCatalogView()
//            NavigationStack(path: $router.path) {
//                LoginWrapperView()
//                    .navigationDestination(for: Route.self) { route in
//                        switch route {
//                        case .login:
//                            LoginWrapperView()
//                        case .main:
//                            MainView()
//                        }
//                    }
//            }
//            .environment(\.diContainer, container)
        }
    }
}
