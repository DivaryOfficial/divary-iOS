//
//  AuthResponse.swift
//  SOAPFT
//
//  Created by 홍지우 on 7/7/25.
//

import Foundation

// 카카오 로그인 응답 DTO
struct KakaoResponseDTO: Codable {
    let accessToken: String
    let refreshToken: String
    let isNewUser: Bool
    let message: String

//    enum CodingKeys: String, CodingKey {
//        case accessToken = "access_token"
//        case refreshToken = "refresh_token"
//        case isNewUser
//        case message
//    }
}

// 네이버 로그인 응답 DTO
struct NaverResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
    let isNewUser: Bool
    let message: String
}

// 토큰 갱신 응답 DTO
struct TokenResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
}

// 닉네임 생성 테스트 DTO
struct NicknameResponseDTO: Decodable {
    let message: String
    let nickname: String
}
