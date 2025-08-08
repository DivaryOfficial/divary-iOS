//
//  DiaryImageModel.swift
//  Divary
//
//  Created by 김나영 on 8/7/25.
//

import Foundation
import SwiftUI

final class FramedImageDTO: ObservableObject, Identifiable {
    let id = UUID()
    @Published var image: Image
    @Published var caption: String
    @Published var frameColor: FrameColor
    @Published var date: String
    
    init(image: Image, caption: String, frameColor: FrameColor, date: String) {
        self.image = image
        self.caption = caption
        self.frameColor = frameColor
        self.date = date
    }
}

enum FrameColor: CaseIterable {
    case origin
    case white
    case ivory
    case pastelPink
    case pastelBlue
    case wood
    case black
    
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
    
    var innerCornerRadius: CGFloat {
        return 1.6
    }
}

extension FramedImageDTO {
    func copy() -> FramedImageDTO {
        FramedImageDTO(
            image: self.image,
            caption: self.caption,
            frameColor: self.frameColor,
            date: self.date
        )
    }
}

extension Array where Element == FramedImageDTO {
    func deepCopied() -> [FramedImageDTO] {
        map { $0.copy() }
    }
}
