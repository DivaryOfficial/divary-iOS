//
//  DrawingStore.swift
//  Divary
//
//  Created by 김나영 on 8/9/25.
//

import Foundation
import PencilKit

struct DrawingStore {
    private static func baseDir() -> URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let drawings = dir.appendingPathComponent("Drawings", isDirectory: true)
        if !FileManager.default.fileExists(atPath: drawings.path) {
            try? FileManager.default.createDirectory(at: drawings, withIntermediateDirectories: true)
        }
        return drawings
    }
    
    private static func fileURL(for diaryId: Int) -> URL {
        baseDir().appendingPathComponent("\(diaryId).json")
    }
    
    static func save(diaryId: Int, drawing: PKDrawing, offsetY: CGFloat) throws {
        let data = drawing.dataRepresentation()
        let base64 = data.base64EncodedString()
        let dto = DrawingContentDTO(base64: base64, offsetY: offsetY)
        let encoded = try JSONEncoder().encode(dto)
        try encoded.write(to: fileURL(for: diaryId), options: .atomic)
    }
    
    static func load(diaryId: Int) throws -> (drawing: PKDrawing, offsetY: CGFloat) {
        let url = fileURL(for: diaryId)
        let data = try Data(contentsOf: url)
        let dto = try JSONDecoder().decode(DrawingContentDTO.self, from: data)
        guard let drawingData = Data(base64Encoded: dto.base64) else {
            throw NSError(domain: "DrawingStore", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid base64"])
        }
        let drawing = try PKDrawing(data: drawingData)
        return (drawing, dto.offsetY)
    }
    
    static func exists(diaryId: Int) -> Bool {
        FileManager.default.fileExists(atPath: fileURL(for: diaryId).path)
    }
}
