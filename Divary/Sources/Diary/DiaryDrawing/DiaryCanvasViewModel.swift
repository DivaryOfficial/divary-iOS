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
//        toolPicker.setVisible(!toolPicker.isVisible, forFirstResponder: canvas)
        toolPicker.setVisible(false, forFirstResponder: canvas)
        showCanvas = false
    }

    private func startMonitoringUndoRedo() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self else { return }
            canUndo = canvas.undoManager?.canUndo ?? false
            canRedo = canvas.undoManager?.canRedo ?? false
        }
    }
    
    func saveDrawingWithOffset(offsetY: CGFloat) {
        let drawing = canvas.drawing
        do {
            try DrawingStore.save(diaryId: diaryId, drawing: drawing, offsetY: offsetY)
        } catch {
            print("saveDrawingWithOffset error: \(error)")
        }
    }
    
    func loadDrawingIfExists() {
        guard DrawingStore.exists(diaryId: diaryId) else { return }
        do {
            let loaded = try DrawingStore.load(diaryId: diaryId)
            canvas.drawing = loaded.drawing
            // 편집 시작 시 저장돼 있던 offset으로 시작하고 싶으면, CanvasView의 offsetY를 그대로 쓰면 됨
            // (DiaryCanvasView에서 offsetY를 이미 주입하므로 여기서 별도 조정 불필요)
        } catch {
            print("loadDrawingIfExists error: \(error)")
        }
    }
    
    func loadDrawingFromString(_ base64String: String) {
        guard let data = Data(base64Encoded: base64String) else {
            print("base64 복호화 실패")
            return
        }
        
        do {
            let drawing = try PKDrawing(data: data)
            canvas.drawing = drawing
        } catch {
            print("PKDrawing 복원 실패: \(error.localizedDescription)")
        }
    }
}
