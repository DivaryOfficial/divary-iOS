//
//  DiaryModel.swift
//  Divary
//
//  Created by 바견규 on 7/22/25.
//

import SwiftUI
import PhotosUI
import RichTextKit


final class DiaryBlock: ObservableObject, Identifiable, Equatable {
    let id: UUID = UUID()
    @Published var content: Content
    
    enum Content: Equatable {
        case text(RichTextContent)
        case image(UIImage)
        
        static func == (lhs: Content, rhs: Content) -> Bool {
            switch (lhs, rhs) {
            case (.text(let lhsContent), .text(let rhsContent)):
                return lhsContent == rhsContent
            case (.image(let lhsImage), .image(let rhsImage)):
                return lhsImage.pngData() == rhsImage.pngData()  // 이미지 비교
            default:
                return false
            }
        }
    }
    
    init(content: Content) {
        self.content = content
    }
    
    static func == (lhs: DiaryBlock, rhs: DiaryBlock) -> Bool {
        lhs.id == rhs.id
    }
}

final class RichTextContent: ObservableObject, Equatable {
    @Published var text: NSAttributedString
    @Published var context: RichTextContext  // 이 부분이 추가되어야 함
    
    var rtfData: Data? {
        try? text.data(from: NSRange(location: 0, length: text.length),
                       documentAttributes: [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.rtf])
    }
    
    init(text: NSAttributedString) {
        self.text = text
        self.context = RichTextContext()
        self.context.setAttributedString(to: text)
    }
    
    convenience init?(rtfData: Data) {
        guard let attrStr = try? NSAttributedString(data: rtfData,
                                                    options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf],
                                                    documentAttributes: nil) else {
            return nil
        }
        self.init(text: attrStr)
    }
    
    static func == (lhs: RichTextContent, rhs: RichTextContent) -> Bool {
        lhs.text == rhs.text
    }
}

struct DiaryBlockDTO: Codable {
    let id: String
    let content: DiaryContentDTO

    enum DiaryContentDTO: Codable {
        case text(RichTextContentDTO)
        case image(URL)

        enum CodingKeys: String, CodingKey {
            case type, data
        }

        enum ContentType: String, Codable {
            case text, image
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(ContentType.self, forKey: .type)
            switch type {
            case .text:
                let data = try container.decode(RichTextContentDTO.self, forKey: .data)
                self = .text(data)
            case .image:
                let url = try container.decode(URL.self, forKey: .data)
                self = .image(url)
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .text(let data):
                try container.encode(ContentType.text, forKey: .type)
                try container.encode(data, forKey: .data)
            case .image(let url):
                try container.encode(ContentType.image, forKey: .type)
                try container.encode(url, forKey: .data)
            }
        }
    }
}

struct RichTextContentDTO: Codable {
    let rtfData: Data
}
