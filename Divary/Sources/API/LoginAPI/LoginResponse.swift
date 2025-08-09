//
//  AuthResponse.swift
//  Divary
//
//  Created by 바견규 on 8/8/25.
//

import Foundation

// Login Response DTOs
struct LoginApiResponse: Codable {
    let timestamp: String
    let status: Int
    let code: String
    let message: String
    let data: LoginDataResponse
}

struct LoginDataResponse: Codable {
    let token: String
    // isNewUser, refreshToken 등이 실제로 없다면 제거
}
