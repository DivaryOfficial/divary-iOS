//
//  AuthService.swift
//  Divary
//
//  Created by 바견규 on 8/8/25.
//

import Foundation
import Moya
import UIKit

final class LoginService : BaseService{
    private let provider = MoyaProvider<LoginAPI>()
    
    /// 기기 고유 ID (한 번 생성되면 키체인에 영구 저장)
    private var deviceID: String {
        let key = "deviceID"
        
        // 1. 키체인에 저장된 값이 있으면 사용
        if let savedID = KeyChainManager.shared.read(forKey: key) {
            return savedID
        }
        
        // 2. identifierForVendor 시도
        if let vendorID = UIDevice.current.identifierForVendor?.uuidString {
            KeyChainManager.shared.save(vendorID, forKey: key)
            print("Device ID saved (from vendor): \(vendorID)")
            return vendorID
        }
        
        // 3. 최후의 수단: 새로 생성하고 키체인에 저장
        let newID = UUID().uuidString
        KeyChainManager.shared.save(newID, forKey: key)
        print("Device ID saved (newly generated): \(newID)")
        return newID
    }
    
    // 구글 로그인
    func googleLogin(accessToken: String, deviceId: String, completion: @escaping (Result<LoginDataResponse, APIError>) -> Void) {
        print("Google Login - Device ID: \(deviceId)")
        provider.request(.googleLogin(accessToken: accessToken, deviceId: deviceId)) { result in
            self.handleResponse(result, completion: completion)
        }
    }
    
    //애플 로그인
    func appleLogin(identityToken: String, deviceId: String, completion: @escaping (Result<LoginDataResponse, APIError>) -> Void) {
        print("Apple Login - Device ID: \(deviceId)")
        provider.request(.appleLogin(identityToken: identityToken, deviceId: deviceId)) { result in
                self.handleResponse(result, completion: completion)
            }
        }
    
    //토큰 재발급
    func reissueToken(refreshToken: String, deviceId: String, completion: @escaping (Result<LoginDataResponse, APIError>) -> Void) {
        print("Reissue Token - Device ID: \(deviceId)")
        provider.request(.reissueToken(refreshToken: refreshToken, deviceId: deviceId)) { result in
                self.handleResponse(result, completion: completion)
            }
        }
    
    //로그아웃
    func logout(socialType: String, completion: @escaping (Result<EmptyResponse, APIError>) -> Void) {
        print("Logout - Social Type: \(socialType), Device ID: \(deviceID)")
        provider.request(.logout(socialType: socialType, deviceId: deviceID)) { result in
                self.handleResponse(result, completion: completion)
            }
        }
    
    //회원탈퇴
    func deleteAccount(completion: @escaping (Result<DeleteAccountDataResponse, APIError>) -> Void) {
        print("🔵 Delete Account Request 시작")
        
        // 키체인에서 AccessToken 읽기
        if let accessToken = KeyChainManager.shared.read(forKey: KeyChainKey.accessToken) {
            print("📌 AccessToken 존재: \(accessToken.prefix(20))...")
        } else {
            print("⚠️ AccessToken이 키체인에 없음")
        }
        
        provider.request(.deleteAccount) { result in
                self.handleResponse(result, completion: completion)
            }
        }
    
}
