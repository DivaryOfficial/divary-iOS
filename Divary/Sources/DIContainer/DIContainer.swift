//
//  DIContainer.swift
//  SOAPFT
//
//  Created by 바견규 on 7/5/25.
//

import SwiftUI
import Combine
import Foundation
import Moya
import Alamofire

final class DIContainer: ObservableObject {
    // 뷰 이동 중앙 집중 관리
    let router: AppRouter
    
    
    // 뷰 수정, 생성, 삭제 시 호출할 데이터
   // let challengeRefreshSubject = PassthroughSubject<Void, Never>()
   // let chatRefreshSubject = PassthroughSubject<Void, Never>()
    
    // 모든 서비스 선언
    let loginService: LoginService
    let notificationService: NotificationService
    let logBookService: LogBookService
    let avatarService: AvatarService
    let imageService: ImageService
    let logDiaryService: LogDiaryService
    let oceanCatalogService: OceanCatalogService
    let tokenManager: TokenManager
  
    //메인 탭바 변수
    @Published var selectedTab: String = "기록"
    

    init(router: AppRouter) {
        self.router = router
        
        self.tokenManager = TokenManager.shared
        
        //Interceptor 생성 (토큰 관리자 주입)
        let interceptor = TokenInterceptor(tokenManager: self.tokenManager)
        
        // Interceptor를 장착한 Session 및 공용 MoyaProvider 생성
        let session = Session(interceptor: interceptor)
        let provider = MoyaProvider<MultiTarget>(session: session) //이 코드로 인해 provider가 실행될때 intercepter 실행
        
        // 각 서비스 초기화
        self.loginService = LoginService(provider: provider)
        self.notificationService = NotificationService()
        self.logBookService = LogBookService.shared
        self.avatarService = AvatarService()
        self.imageService = ImageService()
        self.logDiaryService = LogDiaryService()
        self.oceanCatalogService = OceanCatalogService()
        
        
    }
}

private struct DIContainerKey: EnvironmentKey {
    static var defaultValue: DIContainer = DIContainer(router: AppRouter())
}

extension EnvironmentValues {
    var diContainer: DIContainer {
        get { self[DIContainerKey.self] }
        set { self[DIContainerKey.self] = newValue }
    }
}
