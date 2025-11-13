//
//  MemberAPI.swift
//  Divary
//
//  Created by 김나영 on 11/13/25.
//

import Foundation
import Moya

enum MemberAPI {
    case getProfile
    case updateLevel(level: String)
    case updateGroup(group: String)
    case uploadLicense(image: Data, fileName: String, mimeType: String)
    case getLicense
}

extension MemberAPI: TargetType {

    var baseURL: URL { URL(string: "https://divary.app/api/v1/member")! }

    var path: String {
        switch self {
        case .getProfile:
            return "/profile"
        case .updateLevel:
            return "/level"
        case .updateGroup:
            return "/group"
        case .uploadLicense, .getLicense:
            return "/license"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getProfile, .getLicense:
            return .get
        case .updateLevel, .updateGroup:
            return .patch
        case .uploadLicense:
            return .post
        }
    }

    var sampleData: Data { Data() }

    var task: Task {
        switch self {
        case .getProfile, .getLicense:
            return .requestPlain
            
        case let .updateLevel(level):
            let params = ["level": level]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)

        case let .updateGroup(group):
            let params = ["memberGroup": group]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)

        case let .uploadLicense(image, fileName, mimeType):
            let imageData = MultipartFormData(
                provider: .data(image),
                name: "image",
                fileName: fileName,
                mimeType: mimeType
            )
            return .uploadMultipart([imageData])
        }
        
    
    }

    var headers: [String: String]? {
        [
            "Authorization": "Bearer \(KeyChainManager.shared.read(forKey: KeyChainKey.accessToken) ?? "")",
            "Accept": "*/*"
        ]
    }

    var validationType: ValidationType { .successCodes }
}
