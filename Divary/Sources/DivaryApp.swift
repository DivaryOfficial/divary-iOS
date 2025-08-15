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
                        case .imageSelect(let viewModel, let framedImages):
                            ImageSelectView(
                                viewModel: viewModel,
                                framedImages: framedImages,
                                onComplete: { results in
                                    if let editing = viewModel.editingImageBlock {
                                        if let edited = results.first {
                                            viewModel.updateImageBlock(id: editing.id, to: edited)
                                        } else {
                                            // 편집 중 빈 결과면 삭제
                                            viewModel.deleteBlock(editing)
                                        }
                                        viewModel.editingImageBlock = nil
                                    } else {
                                        // 생성 모드: 여러 장 추가
                                        viewModel.addImages(results)
                                    }
                                    container.router.pop()
                                }
                            )
//                        case .imageSelect(let viewModel, let framedImages):
//                            ImageSelectView(viewModel: viewModel, framedImages: framedImages)
                        case .imageDeco(let framedImages/*, let currentIndex*/):
                            ImageDecoView(framedImages: framedImages/*, currentIndex: currentIndex*/)
                        case .CharacterViewWrapper:
                            CharacterViewWrapper()
                        case .Store(let viewModel):
                            StoreMainView(viewModel: viewModel)
                                .toolbar(.hidden, for: .navigationBar)
                        case .notifications:
                            NotificationView()
                        case .MainTabBar:
                            MainTabbarView()
                                .toolbar(.hidden, for: .navigationBar)
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
                                   .toolbar(.hidden, for: .navigationBar)
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
