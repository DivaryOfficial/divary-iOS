//
//  ImageResponse.swift
//  Divary
//
//  Created by 김나영 on 8/12/25.
//

import Foundation

struct UploadTempImagesDataDTO: Codable {
    let images: [UploadedImageDTO]
    let successCount: Int
    let failureCount: Int
}

struct UploadedImageDTO: Codable {
    let id: Int
    let fileUrl: String
    let originalFilename: String
    let width: Int
    let height: Int
    let type: String?
    let createdAt: String
    let updatedAt: String
    let userId: Int
    let s3Key: String
    let postId: Int?
}
