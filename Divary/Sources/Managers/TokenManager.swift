//
// TokenManager.swift
//  Divary
//
//  Created by 송재곤 on 9/16/25.
//


import Foundation
import Moya
import JWTDecode
import UIKit

final class TokenManager : BaseService{
    
    
    
    /// 앱 전체에서 공유되는 단일 인스턴스
    static let shared = TokenManager()
    
    /// 토큰 재발급 전용 네트워크 클라이언트
    private let authProvider = MoyaProvider<LoginAPI>()
    
    /// 기기 고유 ID
    private var deviceID: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }
    
    
    /// 외부에서 인스턴스를 새로 생성하는 것을 방지
    private override init() {}
    
    func hasValidToken() -> Bool {
        guard let token = KeyChainManager.shared.read(forKey: KeyChainKey.accessToken) else {
            return false // 토큰 없음
        }
        
        do {
            let jwt = try decode(jwt: token)
            
            return !jwt.expired
        } catch {
            // 디코딩 실패는 유효하지 않은 토큰으로 간주
            return false
        }
    }
    
    
    /// 선제적 갱신: 앱 활성화 시 호출되어 토큰 만료 시간을 확인하고, 1시간 이내면 갱신
    func checkAndRefreshTokenIfNeeded() {
        guard let token = KeyChainManager.shared.read(forKey: KeyChainKey.accessToken) else {
            print("AccessToken이 없어 선제적 갱신을 건너뜁니다.")
            return
        }
        
        do {
            let jwt = try decode(jwt: token)
            guard let expirationDate = jwt.expiresAt else { return }
            
            let oneHourFromNow = Date().addingTimeInterval(3600) // 1시간
            
            if expirationDate < oneHourFromNow {
                print("토큰이 1시간 안에 만료될 예정입니다. 갱신을 시작합니다.")
                refreshToken() // 결과를 기다릴 필요 없이 갱신만 요청
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                print("토큰이 아직 유효합니다. 만료 예정: \(formatter.string(from: expirationDate))")
            }
            
        } catch {
            print("JWT 디코딩 실패. 저장된 토큰을 삭제합니다. \(error)")
            KeyChainManager.shared.delete(forKey: KeyChainKey.accessToken)
            KeyChainManager.shared.delete(forKey: KeyChainKey.refreshToken)
        }
    }
    
    
    /// - Parameter completion: 토큰 갱신 성공 여부를 전달하는 클로저
    func refreshToken(completion: ((Bool) -> Void)? = nil) {
        guard let refreshToken = KeyChainManager.shared.read(forKey: KeyChainKey.refreshToken) else {
            print("RefreshToken이 없어 갱신할 수 없습니다.")
            completion?(false)
            return
        }
        
        authProvider.request(.reissueToken(refreshToken: refreshToken, deviceId: self.deviceID)) { result in
            self.handleResponse(result) { (result: Result<LoginDataResponse, APIError>) in
                switch result {
                case .success(let loginData):
                    // 성공 시 토큰 저장
                    KeyChainManager.shared.save(loginData.accessToken, forKey: KeyChainKey.accessToken)
                    
                    KeyChainManager.shared.save(loginData.refreshToken, forKey: KeyChainKey.refreshToken)
                    
                    print("토큰이 성공적으로 갱신되었습니다.")
                    completion?(true)
                    
                case .failure(let error):
                    // 실패 시 토큰 삭제
                    print("토큰 갱신 실패: refresh \(refreshToken)\n deviceId: \(self.deviceID)")
                    print("토큰 갱신 실패 (from handleResponse): \(error.localizedDescription)")
                    KeyChainManager.shared.delete(forKey: KeyChainKey.accessToken)
                    KeyChainManager.shared.delete(forKey: KeyChainKey.refreshToken)
                    completion?(false)
                }
            }
        }
    }
}
