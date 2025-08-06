//
//  OceanCatalogAPI.swift
//  Divary
//
//  Created by 김나영 on 8/6/25.
//

import Foundation
import Moya

enum OceanCatalogAPI {
    case getCardList(type: String?)
    case getCardDetail(cardId: Int)
}

extension OceanCatalogAPI: TargetType {
    var baseURL: URL {
//        guard let baseUrlString = Bundle.main.object(forInfoDictionaryKey: "API_URL") as? String,
//              let url = URL(string: baseUrlString) else {
//            fatalError("❌ API_URL not found or invalid in Info.plist")
//        }
//        return url
        return URL(string: "http://52.79.237.68:8080/")!
    }
    
    var path: String {
        switch self {
        case .getCardList(let type):
            return "/api/v1/cards"
        case .getCardDetail(let cardId):
            return "/api/v1/cards/\(cardId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getCardList, .getCardDetail:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getCardList(let type):
            return .requestParameters(parameters: [
                "type": type ?? ""
            ], encoding: URLEncoding.queryString)
        case .getCardDetail:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getCardList, .getCardDetail:
            return ["Content-Type": "application/json"]
        }
    }
    
    
}
