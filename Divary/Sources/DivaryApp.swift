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
                                .navigationBarBackButtonHidden(true)
                        case .logBookMain(let logBaseId):
                            LogBookMainView(logBaseId: logBaseId)
                        case .CharacterViewWrapper:
                            CharacterViewWrapper()
                        case .Store(let viewModel):
                            StoreMainView(viewModel: viewModel)
                                .navigationBarBackButtonHidden(true)
                        }
                    }
            }
            .environment(\.diContainer, container)
        }
    }
}
