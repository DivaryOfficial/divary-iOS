//
// TokenManager.swift
//  Divary
//
//  Created by 송재곤 on 9/16/25.
//


import Foundation
import JWTDecode
import UIKit

final class TokenManager {
    
    private let loginService: LoginService
    
    // deviceID를 가져오는 로직
    private var deviceID: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }

    init(loginService: LoginService) {
        self.loginService = loginService
    }
    
    /// 토큰 만료 시간을 확인하고 필요한 경우 갱신을 요청하는 메인 함수
    func checkAndRefreshTokenIfNeeded() {
        // 1. 키체인에서 accessToken 읽기
        guard let token = KeyChainManager.shared.read(forKey: KeyChainKey.accessToken) else {
            print("AccessToken이 없어 토큰 갱신을 건너뜁니다.")
            return
        }

        do {
            // 2. JWT 디코딩
            let jwt = try decode(jwt: token)
            
            // 3. 만료 시간 확인
            guard let expirationDate = jwt.expiresAt else { return }
            
            // 현재 시간으로부터 1시간 후의 시간
            let oneHourFromNow = Date().addingTimeInterval(3600) // 3600초 = 1시간
            
            // 4. 만료 시간이 지금으로부터 1시간 이내라면 갱신 로직 실행
            if expirationDate < oneHourFromNow {
                print("토큰이 1시간 안에 만료될 예정입니다. 갱신을 시작합니다.")
                refreshToken()
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                print("토큰이 아직 유효합니다. 만료 예정: \(formatter.string(from: expirationDate))")
            }
            
        } catch {
            print("JWT 디코딩에 실패했습니다: \(error)")
        }
    }
    
    /// 실제 토큰 재발급 API를 호출하는 함수
    private func refreshToken() {
        guard let refreshToken = KeyChainManager.shared.read(forKey: KeyChainKey.refreshToken) else {
            print("RefreshToken이 없어 갱신할 수 없습니다.")
            return
        }
        
        // LoginService를 통해 재발급 API 호출 (deviceID 포함)
        loginService.reissueToken(refreshToken: refreshToken, deviceId: self.deviceID) { result in
            switch result {
            case .success(let response):
                // 성공 시 새로 받은 토큰들을 키체인에 덮어쓰기
                let loginData = response.data
                KeyChainManager.shared.save(loginData.accessToken, forKey: KeyChainKey.accessToken)
                
                //rtr 방식으로 인해 refresh 토큰도 항상 재발급
                KeyChainManager.shared.save(loginData.refreshToken, forKey: KeyChainKey.refreshToken)
            
                print("토큰이 성공적으로 갱신되었습니다.")
                
            case .failure(let error):
                print("토큰 갱신에 실패했습니다: \(error.localizedDescription)")
                // 갱신에 실패하면 (예: 리프레시 토큰 만료) 저장된 모든 토큰을 지우고 사용자에게 다시 로그인을 유도
                KeyChainManager.shared.delete(forKey: KeyChainKey.accessToken)
                KeyChainManager.shared.delete(forKey: KeyChainKey.refreshToken)
            }
        }
    }
}
