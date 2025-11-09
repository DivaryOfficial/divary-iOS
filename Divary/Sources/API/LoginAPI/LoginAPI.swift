//
//  AuthAPI.swift
//  Divary
//
//  Created by 바견규 on 8/8/25.
//


import Foundation
import Moya


enum LoginAPI {
    case googleLogin(accessToken: String, deviceId: String)
    case appleLogin(identityToken: String, deviceId: String)
    case reissueToken(refreshToken: String, deviceId: String)
    case logout(socialType:String, deviceId: String)
    case deleteAccount
}

extension LoginAPI: TargetType {
    var baseURL: URL {
        guard let baseUrlString = Bundle.main.object(forInfoDictionaryKey: "API_URL") as? String,
              let url = URL(string: baseUrlString) else {
            fatalError("❌ API_URL not found or invalid in Info.plist")
        }
        return url
    }

    var path: String {
        switch self {
        case .googleLogin:
            return "/api/v1/auth/GOOGLE/login"
        case .appleLogin:
            return "/api/v1/auth/APPLE/login"
        case .reissueToken:
            return "/api/v1/auth/reissue"
        case .logout(let socialType, _):
            return "/api/v1/auth/\(socialType)/logout"
        case .deleteAccount:
            return "/api/v1/auth/deactivate"
            
        }
    }

    var method: Moya.Method {
        switch self {
        case .googleLogin, .appleLogin, .reissueToken, .logout, .deleteAccount:
            return .post
        }
    }

    var task: Task {
        switch self {
        case .googleLogin(let accessToken, let deviceId):
            let params: [String: Any] = ["accessToken": accessToken, "deviceId": deviceId]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .appleLogin(let identityToken, let deviceId):
            return .requestParameters(parameters: ["accessToken": identityToken, "deviceId": deviceId], encoding: JSONEncoding.default)
        case .reissueToken:
            return .requestPlain
        case .logout(_, let deviceId):
            return .requestParameters(parameters: ["deviceId": deviceId], encoding: JSONEncoding.default)
        case .deleteAccount:
            return .requestPlain
        }
    }

    var headers: [String : String]? {
        var headerDict: [String: String] = [:]
        
        switch self {
        case .reissueToken(let refreshToken, let deviceId):
            headerDict = [
                "refreshToken": refreshToken,
                "Device-Id": deviceId
            ]
            
        case .deleteAccount:
            // 회원탈퇴 API는 AccessToken이 필요
            headerDict = [
                "Content-Type": "application/json",
                "Accept": "*/*",
                "Accept-Language": "ko-KR,ko;q=0.9"
            ]
            
            // 키체인에서 AccessToken 가져와서 Authorization 헤더에 추가
            if let accessToken = KeyChainManager.shared.read(forKey: KeyChainKey.accessToken) {
                headerDict["Authorization"] = "Bearer \(accessToken)"
                print("🔑 [DELETE ACCOUNT] Authorization 헤더 추가됨")
                print("   Bearer \(accessToken.prefix(20))...")
            } else {
                print("⚠️ [DELETE ACCOUNT] AccessToken이 없어서 Authorization 헤더를 추가하지 못함")
            }
            
        default:
            headerDict = [
                "Content-Type": "application/json",
                "Accept": "*/*",
                "Accept-Language": "ko-KR,ko;q=0.9"
            ]
        }
        
        print("📤 [LoginAPI] 최종 헤더:")
        headerDict.forEach { key, value in
            if key == "Authorization" {
                print("   \(key): \(value.prefix(30))...")
            } else {
                print("   \(key): \(value)")
            }
        }
        
        return headerDict
    }

    var sampleData: Data {
        return Data()
    }
}
