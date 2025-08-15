
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
        case image(FramedImageContent)
        
        static func == (lhs: Content, rhs: Content) -> Bool {
            switch (lhs, rhs) {
            case (.text(let lhsContent), .text(let rhsContent)):
                return lhsContent == rhsContent
            case (.image(let lhsFramed), .image(let rhsFramed)):
                return lhsFramed.id == rhsFramed.id
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
    @Published var context: RichTextContext
    
    // RTF 데이터로 변환 (서식 정보 포함)
    var rtfData: Data? {
        guard text.length > 0 else { return nil }
        return try? text.data(
            from: NSRange(location: 0, length: text.length),
            documentAttributes: [
                NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.rtf
            ]
        )
    }
    
    // 순수 텍스트 내용만 (서식 제외)
    var plainText: String {
        return text.string
    }
    
    init(text: NSAttributedString = NSAttributedString()) {
        self.text = text
        self.context = RichTextContext()
        self.context.setAttributedString(to: text)
    }
    
    // RTF 데이터에서 초기화 (서버에서 받은 데이터 - 서식 포함)
    convenience init?(rtfData: Data) {
        guard let attrStr = try? NSAttributedString(
            data: rtfData,
            options: [
                NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf
            ],
            documentAttributes: nil
        ) else {
            return nil
        }
        self.init(text: attrStr)
    }
    
    static func == (lhs: RichTextContent, rhs: RichTextContent) -> Bool {
        lhs.text == rhs.text
    }
}

// 서버 통신용 DTO
struct DiaryBlockDTO: Codable {
    let id: String
    let content: DiaryContentDTO

    enum DiaryContentDTO: Codable {
        case text(RichTextContentDTO)
        case image(FramedImageContentDTO)

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
                self = .image(try container.decode(FramedImageContentDTO.self, forKey: .data))
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .text(let data):
                try container.encode(ContentType.text, forKey: .type)
                try container.encode(data, forKey: .data)
            case .image(let dto):
                try container.encode(ContentType.image, forKey: .type)
                try container.encode(dto, forKey: .data)
            }
        }
    }
}

struct RichTextContentDTO: Codable {
    let rtfData: Data           // RTF 형태 (서식 + 내용)
    let plainText: String       // 순수 텍스트 내용
    let contentLength: Int      // 텍스트 길이

    init(rtfData: Data, plainText: String) {
        self.rtfData = rtfData
        self.plainText = plainText
        self.contentLength = plainText.count
    }
}

struct FramedImageContentDTO: Codable {
    let url: URL
    let caption: String
    let frameColor: Int
    let date: String
}

// MARK: - DiaryBlock과 DTO 간 변환

extension DiaryBlock {
    // DiaryBlock을 DTO로 변환 (서버 전송용)
    func toDTO(uploadedImageURL: URL? = nil) -> DiaryBlockDTO {
        let contentDTO: DiaryBlockDTO.DiaryContentDTO

        switch content {
        case .text(let richTextContent):
            let rtfData = richTextContent.rtfData ?? Data()
            let plainText = richTextContent.plainText
            contentDTO = .text(RichTextContentDTO(rtfData: rtfData, plainText: plainText))

        case .image(let framed):
            // 이미지는 별도 업로드 후 URL 받아서 처리
            // 실제 구현에서는 이미지 업로드 API 호출 후 URL 받아와야 함
            // ⚠️ 실제에선 업로드해서 URL 받아야 함. 여기선 파라미터/플레이스홀더 사용
            let url = uploadedImageURL ?? URL(string: "https://example.com/placeholder")!
            let imageDTO = FramedImageContentDTO(
                url: url,
                caption: framed.caption,
                frameColor: framed.frameColor.rawValue,
                date: framed.date
            )
            contentDTO = .image(imageDTO)
        }

        return DiaryBlockDTO(id: id.uuidString, content: contentDTO)
    }

    // DTO에서 DiaryBlock으로 변환 (서버에서 받은 데이터)
    static func fromDTO(_ dto: DiaryBlockDTO) -> DiaryBlock? {
        guard UUID(uuidString: dto.id) != nil else { return nil }

        let content: Content
        switch dto.content {
        case .text(let textDTO):
            // RTF 데이터에서 서식이 포함된 텍스트 복원
            if let richTextContent = RichTextContent(rtfData: textDTO.rtfData) {
                content = .text(richTextContent)
            } else {
                // RTF 파싱 실패 시 순수 텍스트로 폴백
                let fallbackText = NSAttributedString(string: textDTO.plainText)
                content = .text(RichTextContent(text: fallbackText))
            }

        case .image(let img):
            // URL에서 이미지 로드 (실제 구현에서는 async 처리 필요)
            // URL → Image 로드는 비동기가 맞지만, 여기선 placeholder 처리
            let swiftUIImage: Image = .init(systemName: "photo") // 실제 앱에선 async 로더로 교체
            let frameColor: FrameColor = FrameColor(rawValue: img.frameColor) ?? .origin
            let framed = FramedImageContent(
               image: swiftUIImage,
               caption: img.caption,
               frameColor: frameColor,
               date: img.date
            )
            content = .image(framed)
            }

        let block = DiaryBlock(content: content)
        return block
    }
}

