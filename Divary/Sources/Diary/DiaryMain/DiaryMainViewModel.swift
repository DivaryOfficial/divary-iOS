//
//  DiaryMainViewModel.swift
//  Divary
//
//  Created by 김나영 on 7/6/25.
//

import Foundation
import SwiftUI
import PhotosUI
import PencilKit

class DiaryMainViewModel: ObservableObject {
    @Published var diaryText: String = ""
    @Published var selectedItems: [PhotosPickerItem] = []
    @Published var savedDrawing: PKDrawing? = nil
    @Published var drawingOffsetY: CGFloat = 0
    
    func loadSavedDrawing() {
        guard let data = UserDefaults.standard.data(forKey: "SavedDrawingMeta"),
              let meta = try? JSONDecoder().decode(DrawingMeta.self, from: data),
              let drawingData = Data(base64Encoded: meta.base64),
              let drawing = try? PKDrawing(data: drawingData) else {
            return
        }
        self.savedDrawing = drawing
        self.drawingOffsetY = meta.offsetY
        print(drawingOffsetY)
        print(meta.offsetY)
    }
    
}
