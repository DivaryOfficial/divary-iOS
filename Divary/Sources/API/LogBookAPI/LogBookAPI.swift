//
//  LogBookAPI.swift
//  Divary
//
//  Created by 바견규 on 8/8/25.
//

import Foundation
import Moya

enum LogBookAPI {
    case getLogList(year: Int, saveStatus: String?)
    case getAllLogs
    case getLogBaseDetail(logBaseInfoId: Int)
    case createLogBase(iconType: String, name: String, date: String)
    case createEmptyLogBooks(logBaseInfoId: Int)
    case updateLogBook(logBookId: Int, logData: LogUpdateRequestDTO)
    case deleteLogBase(logBaseInfoId: Int)
    case checkLogExists(date: String)
    case updateLogBaseTitle(logBaseInfoId: Int, name: String)
}

extension LogBookAPI: TargetType {
    var baseURL: URL {
        guard let baseUrlString = Bundle.main.object(forInfoDictionaryKey: "API_URL") as? String,
              let url = URL(string: baseUrlString) else {
            fatalError("⚠️ API_URL not found or invalid in Info.plist")
        }
        return url
    }

    var path: String {
        switch self {
        case .getLogList:
            return "/api/v1/logs"
        case .getAllLogs:
            return "/api/v1/logs/all"
        case .getLogBaseDetail(let logBaseInfoId), .deleteLogBase(let logBaseInfoId):
            return "/api/v1/logs/\(logBaseInfoId)"  // updateLogBaseTitle 제거
        case .createLogBase:
            return "/api/v1/logs"
        case .createEmptyLogBooks(let logBaseInfoId):
            return "/api/v1/logs/\(logBaseInfoId)"
        case .updateLogBook(let logBookId, _):
            return "/api/v1/logs/\(logBookId)"
        case .updateLogBaseTitle(let logBaseInfoId, _):
            return "/api/v1/logs/\(logBaseInfoId)/name"  // 이제 실행됨!
        case .checkLogExists:
            return "/api/v1/logs/exists"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getLogList, .getAllLogs, .getLogBaseDetail, .checkLogExists:
            return .get
        case .createLogBase, .createEmptyLogBooks:
            return .post
        case .updateLogBook:
            return .put
        case .updateLogBaseTitle:
            return .patch
        case .deleteLogBase:
            return .delete
        }
    }

    var task: Task {
        switch self {
        case .getLogList(let year, let saveStatus):
            var params: [String: Any] = ["year": year]
            if let saveStatus = saveStatus {
                params["saveStatus"] = saveStatus
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
            
        case .createLogBase(let iconType, let name, let date):
            let params: [String: Any] = [
                "iconType": iconType,
                "name": name,
                "date": date
            ]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .updateLogBook(_, let logData):
            return .requestJSONEncodable(logData)
            
        case .updateLogBaseTitle(_, let name):
            let params: [String: Any] = ["name": name]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .checkLogExists(let date):
            return .requestParameters(parameters: ["date": date], encoding: URLEncoding.queryString)
            
        case .getAllLogs, .getLogBaseDetail, .createEmptyLogBooks, .deleteLogBase:
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
            print("⚠️ accessToken 없음: 인증이 필요한 요청입니다.")
        }
        
        return headers
    }

    var sampleData: Data {
        return Data()
    }
}
