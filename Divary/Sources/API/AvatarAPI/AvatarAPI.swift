//
//  AvatarAPI.swift
//  Divary
//
//  Created by 바견규 on 8/8/25.
//

import Foundation
import Moya

enum AvatarAPI {
    case getAvatar
    case saveAvatar(avatar: AvatarRequestDTO)
}

extension AvatarAPI: TargetType {
    var baseURL: URL {
        guard let baseUrlString = Bundle.main.object(forInfoDictionaryKey: "API_URL") as? String,
              let url = URL(string: baseUrlString) else {
            fatalError("❌ API_URL not found or invalid in Info.plist")
        }
        return url
    }

    var path: String {
        switch self {
        case .getAvatar, .saveAvatar:
            return "/api/v1/avatar"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getAvatar:
            return .get
        case .saveAvatar:
            return .put
        }
    }

    var task: Task {
        switch self {
        case .getAvatar:
            return .requestPlain
        case .saveAvatar(let avatar):
            return .requestJSONEncodable(avatar)
        }
    }

    var headers: [String : String]? {
        var headers: [String: String] = [
            "Accept-Language": "ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7",
            "accept": "application/json",
        ]
        
        if let accessToken = KeyChainManager.shared.readAccessToken() {
            headers["Authorization"] = "Bearer \(accessToken)"
        } else {
            DebugLogger.warning("accessToken 없음: 인증이 필요한 요청입니다.")
        }
        
        return headers
    }

    var sampleData: Data {
        return Data()
    }
}
