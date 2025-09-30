//
//  AuthService.swift
//  Divary
//
//  Created by 바견규 on 8/8/25.
//

import Foundation
import Moya

final class LoginService : BaseService{
    private let provider = MoyaProvider<LoginAPI>()
    
    
    // 구글 로그인
    func googleLogin(accessToken: String, deviceId: String, completion: @escaping (Result<LoginDataResponse, APIError>) -> Void) {
        provider.request(.googleLogin(accessToken: accessToken, deviceId: deviceId)) { result in
            self.handleResponse(result, completion: completion)
        }
    }
    
    //애플 로그인
    func appleLogin(identityToken: String, deviceId: String, completion: @escaping (Result<LoginDataResponse, APIError>) -> Void) {
        provider.request(.appleLogin(identityToken: identityToken, deviceId: deviceId)) { result in
                self.handleResponse(result, completion: completion)
            }
        }
    
    //토큰 재발급
    func reissueToken(refreshToken: String, deviceId: String, completion: @escaping (Result<LoginDataResponse, APIError>) -> Void) {
        provider.request(.reissueToken(refreshToken: refreshToken, deviceId: deviceId)) { result in
                self.handleResponse(result, completion: completion)
            }
        }
    
}
