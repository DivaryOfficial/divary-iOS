import SwiftUI

@main
struct DivaryApp: App {
    @StateObject private var router = AppRouter()
    // DIContainer 인스턴스 생성
    private var container: DIContainer
    
    
    init() {
        // DIContainer 생성
        let router = AppRouter()
        self._router = StateObject(wrappedValue: router)
        self.container = DIContainer(router: router)
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                DiaryMainView(showCanvas: .constant(false))
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                            
                        case .login:
                            LoginView()
                            
                        }
                    }
            }

        }
    }
}
