//
//  APIError.swift
//  Divary
//
//  Created by 김나영 on 8/6/25.
//

import Foundation
import Moya


enum APIError: Error {
    case resultNil
    case moya(error: MoyaError)
    case responseState(status: Int, code: String, message: String)
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .resultNil:
            return "Result Nil"
        case .moya(let error):
            return "Moya Error - \(error.localizedDescription)"
        case .responseState(let status, let code, let message):
            return "Response Status: \(status) \(code) \(message)"
        }
    }
}

