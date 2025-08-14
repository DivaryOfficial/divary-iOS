//
//  ImageAPI.swift
//  Divary
//
//  Created by 김나영 on 8/12/25.
//

import Foundation
import Moya

enum ImageAPI {
    case uploadTemp(files: [Data], token: String, mimeType: String = "image/jpeg")
}

extension ImageAPI: TargetType {
    var baseURL: URL { URL(string: "https://divary.app")! }

    var path: String {
        switch self {
        case .uploadTemp:
            return "/api/v1/images/upload/temp"
        }
    }

    var method: Moya.Method {
        switch self {
        case .uploadTemp: return .post
        }
    }

    var sampleData: Data { Data() }

    var task: Task {
        switch self {
        case let .uploadTemp(files, _, mimeType):
            let parts: [MultipartFormData] = files.enumerated().map { idx, data in
                MultipartFormData(
                    provider: .data(data),
                    name: "files",
                    fileName: "upload_\(idx).jpg",
                    mimeType: mimeType
                )
            }
            return .uploadMultipart(parts)
        }
    }

    var headers: [String : String]? {
        switch self {
        case let .uploadTemp(_, token, _):
            // Content-Type(multipart boundary)는 지정하지 않음 (Moya가 자동 설정)
            return [
                "Authorization": "Bearer \(token)",
                "Accept": "*/*"
            ]
        }
    }
}
