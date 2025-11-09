//
//  AuthResponse.swift
//  Divary
//
//  Created by 바견규 on 8/8/25.
//

import Foundation

// Login Data Response
struct LoginDataResponse: Codable {
    let accessToken: String
    let refreshToken: String
}

// Empty Response (로그아웃 등 data가 빈 객체인 경우)
struct EmptyResponse: Codable {
}

// Delete Account Data Response
struct DeleteAccountDataResponse: Codable {
    let scheduledDeletionAt: String
}

// Type Aliases - DefaultResponse 활용
typealias LoginResponse = DefaultResponse<LoginDataResponse>
typealias LogoutResponse = DefaultResponse<EmptyResponse>
typealias DeleteAccountResponse = DefaultResponse<DeleteAccountDataResponse>

