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
                            MainWrapperView()    // <- 아래 #3에서 추가할 래퍼
                        case .logBookMain(let id):
                            LogBookMainView(logBaseId: id)
                                .navigationBarBackButtonHidden(true)
                        case .character(let isEditing):
                            CharacterView(isPetEditingMode: .constant(isEditing))
                        case .notifications:
                            NotificationView()
                        }
                    }
            }
            .environment(\.diContainer, container)
        }
    }
}
