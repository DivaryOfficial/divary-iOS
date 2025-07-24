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
    
    func loadSavedDrawing() {
        guard let base64 = UserDefaults.standard.string(forKey: "SavedDrawing"),
              let data = Data(base64Encoded: base64),
              let drawing = try? PKDrawing(data: data) else {
            return
        }
        self.savedDrawing = drawing
    }
    
}
