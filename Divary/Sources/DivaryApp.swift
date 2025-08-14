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
                        case .locationSearch:
                            LocationSearchView(
                                       currentValue: container.router.locationSearchText,
                                       placeholder: "다이빙 스팟 검색",
                                       onLocationSelected: { selectedLocation in
                                           // 선택된 위치를 AppRouter에 저장
                                           container.router.locationSearchText = selectedLocation
                                       }
                                   )
                                   .environment(\.diContainer, container)
                            .navigationBarBackButtonHidden(true)
                        case .oceanCatalog:
                            OceanCatalogView()
                        case .oceanCreatureDetail(let creature):
                            OceanCreatureDetailView(creature: creature)
                        }
                    }
            }
            .environmentObject(container)
            .environment(\.diContainer, container)
        }
    }
}
