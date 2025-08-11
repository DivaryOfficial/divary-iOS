import SwiftUI

@main
struct DivaryApp: App {
    @StateObject private var router = AppRouter()
    private var container: DIContainer
    
    init() {
        let appRouter = AppRouter()
        self._router = StateObject(wrappedValue: appRouter)
        self.container = DIContainer(router: appRouter)
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
                        case .characterView:
                            CharacterView(isPetEditingMode: .constant(false))
                        }
                    }
            }
            .environment(\.diContainer, container)
        }
    }
}
