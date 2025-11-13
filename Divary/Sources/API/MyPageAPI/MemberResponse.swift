//
//  MemberResponse.swift
//  Divary
//
//  Created by 김나영 on 11/13/25.
//

import Foundation

// data가 없는 응답을 위한 비어있는 Codable struct
struct EmptyData: Codable {}

// 프로필 조회
struct MemberProfileResponse: Codable {
    let id: String
    let memberGroup: String
    let level: String
    let accumulations: Int
}

// 자격증 업로드 및 조회
struct LicenseResponse: Codable {
    let url: String
}

//// 레벨 업데이트
//struct LevelUpdateResponse: Codable { }
//
//// 그룹 업데이트
//struct GroupUpdateResponse: Codable { }

