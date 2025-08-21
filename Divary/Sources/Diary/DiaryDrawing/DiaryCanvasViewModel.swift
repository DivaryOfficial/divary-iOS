//
//  DiaryCanvasViewModel.swift
//  Divary
//
//  Created by 김나영 on 7/22/25.
//

import Foundation
import PencilKit
import Combine
import SwiftUI

final class DiaryCanvasViewModel: ObservableObject {
    let canvas: PKCanvasView = PKCanvasView()
    let toolPicker: PKToolPicker = PKToolPicker()

    @Published var canUndo: Bool = false
    @Published var canRedo: Bool = false
    
    @Binding var showCanvas: Bool
    private let diaryId: Int

    private var timer: Timer?

    init(showCanvas: Binding<Bool>, diaryId: Int) {
        _showCanvas = showCanvas
        self.diaryId = diaryId
        startMonitoringUndoRedo()
    }

    deinit {
        timer?.invalidate()
    }

    func undo() {
        canvas.undoManager?.undo()
    }

    func redo() {
        canvas.undoManager?.redo()
    }

    func dismissCanvas() {
        toolPicker.setVisible(false, forFirstResponder: canvas)
        showCanvas = false
    }

    // Undo, Redo 버튼 활성화 모니터링
    private func startMonitoringUndoRedo() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self else { return }
            canUndo = canvas.undoManager?.canUndo ?? false
            canRedo = canvas.undoManager?.canRedo ?? false
        }
    }
    
//    func saveDrawingWithOffset(offsetY: CGFloat) {
//        let drawing = canvas.drawing
//        do {
//            try DrawingStore.save(diaryId: diaryId, drawing: drawing, offsetY: offsetY)
//        } catch {
//            print("saveDrawingWithOffset error: \(error)")
//        }
//    }
    
    func loadDrawingIfExists() {
        guard DrawingStore.exists(diaryId: diaryId) else { return }
        do {
            let loaded = try DrawingStore.load(diaryId: diaryId)
            canvas.drawing = loaded.drawing
        } catch {
            print("loadDrawingIfExists error: \(error)")
        }
    }
}
