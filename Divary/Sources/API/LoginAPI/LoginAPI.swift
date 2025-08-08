//
//  AuthAPI.swift
//  Divary
//
//  Created by 바견규 on 8/8/25.
//


import Foundation
import Moya


enum LoginAPI {
    case googleLogin(accessToken: String)
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
        }
    }

    var method: Moya.Method {
        switch self {
        case .googleLogin:
            return .post
        }
    }

    var task: Task {
        switch self {
        case .googleLogin(let accessToken):
            let params: [String: Any] = ["accessToken": accessToken]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }

    var headers: [String : String]? {
        return [
            "Content-Type": "application/json",
            "Accept": "*/*",
            "Accept-Language": "ko-KR,ko;q=0.9"
        ]
    }

    var sampleData: Data {
        return Data()
    }
}
