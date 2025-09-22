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
                        case .imageDeco(let framedImages/*, let currentIndex*/):
                            ImageDecoView(framedImages: framedImages/*, currentIndex: currentIndex*/)
                        case .CharacterViewWrapper:
                            CharacterViewWrapper()
                        case .Store(let viewModel):
                            StoreMainView(viewModel: viewModel)
                                .navigationBarBackButtonHidden(true)
                        case .notifications:
                            NotificationView()
                        case .MainTabBar:
                            MainTabbarView()
//                                .toolbar(.hidden, for: .navigationBar)
                                .navigationBarBackButtonHidden(true)
                        case .chatBot:
                            ChatBotView()
//                                .toolbar(.hidden, for: .navigationBar)
                                .navigationBarBackButtonHidden(true)
                        case .locationSearch:
                            LocationSearchView(
                                       currentValue: container.router.locationSearchText,
                                       placeholder: "다이빙 지역을 입력해주세요. ex) 강원도 강릉",
                                       onLocationSelected: { selectedLocation in
                                           container.router.locationSearchText = selectedLocation
                                       }
                                   )
                                   .environment(\.diContainer, container)
//                                   .toolbar(.hidden, for: .navigationBar)
                                   .navigationBarBackButtonHidden(true)
                        case .oceanCatalog:
                            OceanCatalogView()
                        case .oceanCreatureDetail(let creature):
                            OceanCreatureDetailView(creature: creature)
                        case .myPage:
                            MyPageMainView()
                        case .myFriend:
                            MyFriendView()
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
