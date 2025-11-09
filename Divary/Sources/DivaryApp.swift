import SwiftUI

@main
struct DivaryApp: App {
    @StateObject private var router = AppRouter()
    @StateObject private var container: DIContainer
    
    // 앱의 현재 상태(활성, 비활성 등)를 감지하기 위한 변수를 추가합니다.
    @Environment(\.scenePhase) private var scenePhase
    
    
    init() {
        var appRouter = AppRouter()
        self._router = StateObject(wrappedValue: appRouter)
        self._container = StateObject(wrappedValue: DIContainer(router: appRouter))
    }
    
    var body: some Scene {
        WindowGroup {
            
            NavigationStack(path: $router.path) {
                LoginWrapperView()
                    .enableInteractivePopGesture()
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
                            MyPageMainViewWrapper()
                                .navigationBarBackButtonHidden(true)
                        case .myProfile:
                            MyProfileView()
                                .navigationBarBackButtonHidden(true)
                        case .myLicense:
                            MyLicenseView()
                                .navigationBarBackButtonHidden(true)
                        case .myFriend:
                            MyFriendView()
                                .navigationBarBackButtonHidden(true)
                        case .withdraw:
                            WithdrawCheckingViewWrapper()
                                .navigationBarBackButtonHidden(true)
                        }
                    }
            }
            .navigationViewStyle(.stack)
            .environmentObject(container)
            .environment(\.diContainer, container)
            .alert(isPresented: $container.router.showAlert) {
                Alert(
                    title: Text("알림"),
                    message: Text(container.router.alertMessage),
                    dismissButton: .default(Text("확인")) {
                        // AppRouter에 저장된 액션을 실행합니다.
                        container.router.alertAction?()
                        container.router.alertAction = nil
                    }
                )
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // 앱이 활성화되고, 라우터 경로가 비어있지 않을 때 (즉, 로그인 후 다른 화면으로 이동했을 때)
            if newPhase == .active && !container.router.path.isEmpty {
                container.tokenManager.checkAndRefreshTokenIfNeeded()
            }
        }
    }
}
