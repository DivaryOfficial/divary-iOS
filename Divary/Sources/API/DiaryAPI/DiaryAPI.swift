//
//  DiaryAPI.swift
//  Divary
//
//  Created by 김나영 on 8/12/25.
//

import Foundation
import Moya

enum LogDiaryAPI {
    case getDiary(logId: Int, token: String)
    case updateDiary(logId: Int, body: DiaryRequestDTO, token: String)
    case createDiary(logId: Int, body: DiaryRequestDTO, token: String)
}

extension LogDiaryAPI: TargetType {
    var baseURL: URL { URL(string: "https://divary.app")! }

    var path: String {
        switch self {
        case .getDiary(let id, _),
             .updateDiary(let id, _, _),
             .createDiary(let id, _, _):
            return "/api/v1/logs/\(id)/diary"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getDiary:      return .get
        case .updateDiary:   return .put
        case .createDiary:   return .post
        }
    }

    var sampleData: Data { Data() }

    var task: Task {
        switch self {
        case .getDiary:
            return .requestPlain

        case .updateDiary(_, let body, _),
             .createDiary(_, let body, _):
            return .requestJSONEncodable(body)
        }
    }

    var headers: [String : String]? {
        switch self {
        case .getDiary(_, let token),
             .updateDiary(_, _, let token),
             .createDiary(_, _, let token):
            return [
                "Authorization": "Bearer \(token)",
                "Accept": "*/*",
                "Content-Type": "application/json"
            ]
        }
    }
}
