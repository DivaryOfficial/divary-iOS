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

    private var timer: Timer?

    init(showCanvas: Binding<Bool>) {
        _showCanvas = showCanvas
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
    
    func saveDrawingToFile() {
        let drawing = canvas.drawing
        let data = drawing.dataRepresentation()

        let url = drawingFileURL()

        do {
            try data.write(to: url)
            print("✅ Drawing saved at \(url.path)")
            showCanvas = false
        } catch {
            print("❌ Failed to save drawing: \(error)")
        }
    }
    
    func loadDrawingFromFile() {
        let url = drawingFileURL()

        guard FileManager.default.fileExists(atPath: url.path) else {
            print("⚠️ No drawing file found at \(url.path)")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let drawing = try PKDrawing(data: data)
            canvas.drawing = drawing
            print("✅ Drawing loaded.")
        } catch {
            print("❌ Failed to load drawing: \(error)")
        }
    }
    
    private func drawingFileURL() -> URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return directory.appendingPathComponent("drawing.pkdraw")
    }
}
