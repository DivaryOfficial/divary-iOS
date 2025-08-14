//
//  DiaryResponse.swift
//  Divary
//
//  Created by 김나영 on 8/12/25.
//

import Foundation

struct DiaryResponseDTO: Codable { // 서버가 보내는 일기 정보
    let diaryId: Int
    let logId: Int
    let contents: [DiaryContentDTO]
}

enum DiaryContentType: String, Codable {
    case text
    case image
    case drawing
}

struct DiaryContentDTO: Codable {
    let type: DiaryContentType
    // text
    let rtfData: String?
    // image
    let imageData: DiaryImageDataDTO?
    // drawing
    let drawingData: DiaryDrawingDataDTO?
}

struct DiaryImageDataDTO: Codable {
    let tempFilename: String
    let caption: String
    let frameColor: String
    let date: String
}

struct DiaryDrawingDataDTO: Codable {
    let base64: String
    let scrollY: Double
}

struct DiaryRequestDTO: Codable { // 서버로 보낼 데이터
    let contents: [DiaryContentDTO]
}
