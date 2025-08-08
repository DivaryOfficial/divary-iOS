//
//  LogBookAPI.swift
//  Divary
//
//  Created by 바견규 on 8/8/25.
//

import Foundation
import Moya

enum LogBookAPI {
    case getLogList(year: Int)
    case getLogDetail(id: Int)
    case createLog(iconType: String, name: String, date: String)
    case updateLog(id: Int, logData: LogUpdateRequestDTO)
    case createEmptyLog(id: Int)
    case deleteLog(id: Int)
    case updateLogName(id: Int, name: String)
    case checkLogExists(date: String)
}

extension LogBookAPI: TargetType {
    var baseURL: URL {
        guard let baseUrlString = Bundle.main.object(forInfoDictionaryKey: "API_URL") as? String,
              let url = URL(string: baseUrlString) else {
            fatalError("❌ API_URL not found or invalid in Info.plist")
        }
        return url
    }

    var path: String {
        switch self {
        case .getLogList:
            return "/api/v1/logs"
        case .getLogDetail(let id), .updateLog(let id, _), .deleteLog(let id), .updateLogName(let id, _):
            return "/api/v1/logs/\(id)"
        case .createLog:
            return "/api/v1/logs"
        case .createEmptyLog(let id):
            return "/api/v1/logs/\(id)"
        case .checkLogExists:
            return "/api/v1/logs/exists"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getLogList, .getLogDetail, .checkLogExists:
            return .get
        case .createLog, .createEmptyLog:
            return .post
        case .updateLog:
            return .put
        case .deleteLog:
            return .delete
        case .updateLogName:
            return .patch
        }
    }

    var task: Task {
        switch self {
        case .getLogList(let year):
            return .requestParameters(parameters: ["year": year], encoding: URLEncoding.queryString)
            
        case .createLog(let iconType, let name, let date):
            let params: [String: Any] = [
                "iconType": iconType,
                "name": name,
                "date": date
            ]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .updateLog(_, let logData):
            return .requestJSONEncodable(logData)
            
        case .updateLogName(_, let name):
            let params: [String: Any] = ["name": name]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .checkLogExists(let date):
            return .requestParameters(parameters: ["date": date], encoding: URLEncoding.queryString)
            
        case .getLogDetail, .createEmptyLog, .deleteLog:
            return .requestPlain
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
            print("❌ accessToken 없음: 인증이 필요한 요청입니다.")
        }
        
        return headers
    }

    var sampleData: Data {
        return Data()
    }
}
