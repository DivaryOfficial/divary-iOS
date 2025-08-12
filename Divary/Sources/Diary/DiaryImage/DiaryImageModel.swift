//
//  DiaryImageModel.swift
//  Divary
//
//  Created by 김나영 on 8/7/25.
//

import Foundation
import SwiftUI

final class FramedImageContent: ObservableObject, Identifiable {
    let id = UUID()
    @Published var image: Image
    @Published var caption: String
    @Published var frameColor: FrameColor
    @Published var date: String
    
    var originalData: Data?        // 포토에서 가져온 원본(업로드용)
    var tempFilename: String?      // 업로드 결과 URL(서버가 요구)
    
    init(image: Image, caption: String, frameColor: FrameColor, date: String) {
        self.image = image
        self.caption = caption
        self.frameColor = frameColor
        self.date = date
    }
}

enum FrameColor: Int, CaseIterable, Codable {
    case origin = 0
    case white = 1
    case ivory = 2
    case pastelPink = 3
    case pastelBlue = 4
    case wood = 5
    case black = 6
    
    var frameColor: Color {
        switch self {
        case .origin:
            return .clear
        case .white:
            return Color(.white)
        case .ivory:
            return Color(.ivory)
        case .pastelPink:
            return Color(.pastelPink)
        case .pastelBlue:
            return Color(.pastelBlue)
        case .wood:
            return Color(.wood)
        case .black:
            return Color(.black)
        }
    }
}

extension FramedImageContent {
    func copy() -> FramedImageContent {
        FramedImageContent(
            image: self.image,
            caption: self.caption,
            frameColor: self.frameColor,
            date: self.date
        )
    }
}

extension Array where Element == FramedImageContent {
    func deepCopied() -> [FramedImageContent] {
        map { $0.copy() }
    }
}
