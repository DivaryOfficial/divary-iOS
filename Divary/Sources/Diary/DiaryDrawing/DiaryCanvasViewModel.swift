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
            showCanvas = false
        } catch {
        }
    }
    
    func loadDrawingFromFile() {
        let url = drawingFileURL()

        guard FileManager.default.fileExists(atPath: url.path) else {
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let drawing = try PKDrawing(data: data)
            canvas.drawing = drawing
        } catch { }
    }
    
    private func drawingFileURL() -> URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return directory.appendingPathComponent("drawing.pkdraw")
    }
}
