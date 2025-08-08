//
//  NotificationAPI.swift
//  Divary
//
//  Created by 바견규 on 8/8/25.
//

import Foundation
import Moya

enum NotificationAPI {
    case getNotifications
    case markAsRead(id: Int)
}

extension NotificationAPI: TargetType {
    var baseURL: URL {
        guard let baseUrlString = Bundle.main.object(forInfoDictionaryKey: "API_URL") as? String,
              let url = URL(string: baseUrlString) else {
            fatalError("❌ API_URL not found or invalid in Info.plist")
        }
        return url
    }

    var path: String {
        switch self {
        case .getNotifications:
            return "/api/v1/notification"
        case .markAsRead:
            return "/api/v1/notification/read"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getNotifications:
            return .get
        case .markAsRead:
            return .patch
        }
    }

    var task: Task {
        switch self {
        case .getNotifications:
            return .requestPlain
        case .markAsRead(let id):
            let params: [String: Any] = ["id": id]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }

    var headers: [String : String]? {
        var baseHeaders: [String: String] = [
            "Accept": "*/*",
            "Accept-Language": "ko-KR,ko;q=0.9"
        ]
        
        switch self {
        case .markAsRead:
            baseHeaders["Content-Type"] = "application/json"
        default:
            break
        }
        
        return baseHeaders
    }

    var sampleData: Data {
        return Data()
    }
}
