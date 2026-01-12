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
    
    private let router: AppRouter
    private let authProvider = MoyaProvider<LoginAPI>()
    
    private var deviceID: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }
    
    private var isRefreshing = false
    private var waiters: [(Bool) -> Void] = []
    private let refreshQueue = DispatchQueue(label: "token.refresh.queue")
    
    init(router: AppRouter) {
        self.router = router
        super.init()
    }

    // MARK: - Public Methods
    
    /// 앱 시작 시 자동 로그인 가능 여부 확인 (동기)
    func hasValidToken() -> Bool {
        if let accessToken = KeyChainManager.shared.read(forKey: KeyChainKey.accessToken) {
            do {
                let jwt = try decode(jwt: accessToken)
                if !jwt.expired { return true }
            } catch {
                DebugLogger.token("AccessToken 디코딩 실패: \(error)")
                KeyChainManager.shared.delete(forKey: KeyChainKey.accessToken)
            }
        }
        
        guard let refreshTokenValue = KeyChainManager.shared.read(forKey: KeyChainKey.refreshToken) else {
            DebugLogger.token("RefreshToken이 없어 자동 로그인을 할 수 없습니다.")
            return false
        }
        
        do {
            let refreshJwt = try decode(jwt: refreshTokenValue)
            
            if refreshJwt.expired {
                DebugLogger.token("RefreshToken도 만료되었습니다. 재로그인이 필요합니다.")
                KeyChainManager.shared.delete(forKey: KeyChainKey.accessToken)
                KeyChainManager.shared.delete(forKey: KeyChainKey.refreshToken)
                return false
            }
            
            DebugLogger.token("RefreshToken이 유효합니다. 자동 로그인이 가능합니다.")
            return true
        } catch {
            DebugLogger.token("RefreshToken 디코딩 실패: \(error)")
            KeyChainManager.shared.delete(forKey: KeyChainKey.accessToken)
            KeyChainManager.shared.delete(forKey: KeyChainKey.refreshToken)
            return false
        }
    }
    
    /// 앱 시작 시 자동 로그인 가능 여부 확인 및 필요 시 토큰 갱신 (비동기)
    func validateAndRefreshToken(completion: @escaping (Bool) -> Void) {
        if let accessToken = KeyChainManager.shared.read(forKey: KeyChainKey.accessToken) {
            do {
                let jwt = try decode(jwt: accessToken)
                if !jwt.expired {
                    DebugLogger.token("액세스 토큰이 유효합니다. 바로 진입합니다.")
                    completion(true)
                    return
                }
                DebugLogger.token("액세스 토큰이 만료되었습니다.")
            } catch {
                DebugLogger.token("AccessToken 디코딩 실패: \(error)")
                KeyChainManager.shared.delete(forKey: KeyChainKey.accessToken)
            }
        }
        
        guard let refreshTokenValue = KeyChainManager.shared.read(forKey: KeyChainKey.refreshToken) else {
            DebugLogger.token("RefreshToken이 없어 자동 로그인을 할 수 없습니다.")
            completion(false)
            return
        }
        
        do {
            let refreshJwt = try decode(jwt: refreshTokenValue)
            
            if refreshJwt.expired {
                DebugLogger.token("RefreshToken도 만료되었습니다. 재로그인이 필요합니다.")
                KeyChainManager.shared.delete(forKey: KeyChainKey.accessToken)
                KeyChainManager.shared.delete(forKey: KeyChainKey.refreshToken)
                completion(false)
                return
            }
            
            DebugLogger.token("RefreshToken이 유효합니다. 토큰 갱신을 시도합니다...")
            refreshToken { success in
                if success {
                    DebugLogger.success("토큰 갱신 성공! 자동 로그인이 가능합니다.")
                    completion(true)
                } else {
                    DebugLogger.error("토큰 갱신 실패. 재로그인이 필요합니다.")
                    completion(false)
                }
            }
        } catch {
            DebugLogger.token("RefreshToken 디코딩 실패: \(error)")
            KeyChainManager.shared.delete(forKey: KeyChainKey.accessToken)
            KeyChainManager.shared.delete(forKey: KeyChainKey.refreshToken)
            completion(false)
        }
    }
    
    /// 선제적 갱신: 앱 활성화 시 호출되어 토큰 만료 시간을 확인하고, 1시간 이내면 갱신
    func checkAndRefreshTokenIfNeeded() {
        #if DEBUG
        DebugLogger.info("토큰 갱신 필요 여부 체크 시작")
        printTokenStatus()
        #endif
        
        guard let token = KeyChainManager.shared.read(forKey: KeyChainKey.accessToken) else {
            DebugLogger.token("AccessToken이 없어 선제적 갱신을 건너뜁니다.")
            
            if KeyChainManager.shared.read(forKey: KeyChainKey.refreshToken) != nil {
                DebugLogger.token("RefreshToken이 있으므로 토큰 갱신을 시도합니다.")
                refreshToken()
            }
            return
        }
        
        do {
            let jwt = try decode(jwt: token)
            guard let expirationDate = jwt.expiresAt else { return }
            
            let oneHourFromNow = Date().addingTimeInterval(3600)
            
            if expirationDate < oneHourFromNow {
                DebugLogger.token("토큰이 1시간 안에 만료될 예정입니다. 갱신을 시작합니다.")
                refreshToken()
            } else {
                #if DEBUG
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                DebugLogger.token("토큰이 아직 유효합니다. 만료 예정: \(formatter.string(from: expirationDate))")
                #endif
            }
        } catch {
            DebugLogger.token("JWT 디코딩 실패. 저장된 토큰을 삭제합니다. \(error)")
            KeyChainManager.shared.delete(forKey: KeyChainKey.accessToken)
            KeyChainManager.shared.delete(forKey: KeyChainKey.refreshToken)
        }
    }
    
    /// 토큰 갱신
    func refreshToken(completion: ((Bool) -> Void)? = nil) {
        guard let refreshToken = KeyChainManager.shared.read(forKey: KeyChainKey.refreshToken) else {
            DebugLogger.token("RefreshToken이 없어 갱신할 수 없습니다.")
            completion?(false)
            return
        }
        
        authProvider.request(.reissueToken(refreshToken: refreshToken, deviceId: self.deviceID)) { result in
            self.handleResponse(result) { (result: Result<LoginDataResponse, APIError>) in
                switch result {
                case .success(let loginData):
                    KeyChainManager.shared.save(loginData.accessToken, forKey: KeyChainKey.accessToken)
                    KeyChainManager.shared.save(loginData.refreshToken, forKey: KeyChainKey.refreshToken)
                    
                    DebugLogger.success("토큰이 성공적으로 갱신되었습니다.")
                    completion?(true)
                    
                case .failure(let error):
                    DebugLogger.error("토큰 갱신 실패: \(error.localizedDescription)")
                    KeyChainManager.shared.delete(forKey: KeyChainKey.accessToken)
                    KeyChainManager.shared.delete(forKey: KeyChainKey.refreshToken)
                    
                    DispatchQueue.main.async {
                        self.router.alertMessage = "세션이 만료되었습니다. 다시 로그인해주세요."
                        self.router.alertAction = { self.router.popToRoot() }
                        self.router.showAlert = true
                    }
                    completion?(false)
                }
            }
        }
    }
    
    /// 여러 401이 동시에 와도 갱신은 1번만 수행
    func refreshIfNeededSerial(completion: @escaping (Bool) -> Void) {
        refreshQueue.async {
            if self.isRefreshing {
                self.waiters.append(completion)
                return
            }
            self.isRefreshing = true
            self.waiters.append(completion)

            self.refreshToken { ok in
                self.refreshQueue.async {
                    self.isRefreshing = false
                    let cbs = self.waiters
                    self.waiters.removeAll()
                    cbs.forEach { $0(ok) }
                }
            }
        }
    }
    
    // MARK: - Debug & Testing
    #if DEBUG
    
    func printTokenStatus() {
        DebugLogger.separator()
        DebugLogger.log("토큰 상태")
        DebugLogger.separator(60, char: "-")
        
        if let accessToken = KeyChainManager.shared.read(forKey: KeyChainKey.accessToken) {
            do {
                let jwt = try decode(jwt: accessToken)
                let status = jwt.expired ? "❌ 만료됨" : "✅ 유효"
                if let expiresAt = jwt.expiresAt {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let remaining = Int(expiresAt.timeIntervalSinceNow)
                    DebugLogger.log("액세스 토큰: \(status)")
                    DebugLogger.log("  만료 시간: \(formatter.string(from: expiresAt))")
                    DebugLogger.log("  남은 시간: \(remaining)초 (\(remaining / 60)분)")
                }
            } catch {
                DebugLogger.warning("액세스 토큰: 디코딩 실패 - \(error.localizedDescription)")
            }
        } else {
            DebugLogger.log("액세스 토큰: ❌ 없음")
        }
        
        if let refreshTokenValue = KeyChainManager.shared.read(forKey: KeyChainKey.refreshToken) {
            do {
                let jwt = try decode(jwt: refreshTokenValue)
                let status = jwt.expired ? "❌ 만료됨" : "✅ 유효"
                if let expiresAt = jwt.expiresAt {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let remaining = Int(expiresAt.timeIntervalSinceNow)
                    DebugLogger.log("리프레시 토큰: \(status)")
                    DebugLogger.log("  만료 시간: \(formatter.string(from: expiresAt))")
                    DebugLogger.log("  남은 시간: \(remaining)초 (\(remaining / 3600)시간)")
                }
            } catch {
                DebugLogger.warning("리프레시 토큰: 디코딩 실패 - \(error.localizedDescription)")
            }
        } else {
            DebugLogger.log("리프레시 토큰: ❌ 없음")
        }
        
        DebugLogger.separator()
    }
    
    #endif
}
