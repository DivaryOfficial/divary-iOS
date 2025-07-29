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
    
    func saveDrawingWithOffset(offsetY: CGFloat) {
        let drawing = canvas.drawing
        print(drawing.bounds.origin)
        print(drawing.bounds.size)
        let data = drawing.dataRepresentation()
        let base64 = data.base64EncodedString()
        let meta = DrawingMeta(base64: base64, offsetY: offsetY)
        print("캔버스뷰모델 \(meta.offsetY)")

        if let encoded = try? JSONEncoder().encode(meta) {
            UserDefaults.standard.set(encoded, forKey: "SavedDrawingMeta")
        }
    }
    
    // 스트링
//    func saveDrawingAsString() -> String {
//        let drawing = canvas.drawing
//        let data = drawing.dataRepresentation()
//        let base64String = data.base64EncodedString()
//        return base64String
//    }
    
    func loadDrawingFromString(_ base64String: String) {
        guard let data = Data(base64Encoded: base64String) else {
            print("base64 복호화 실패")
            return
        }
        
        do {
            let drawing = try PKDrawing(data: data)
            canvas.drawing = drawing
//            canvas.contentOffset.y =
        } catch {
            print("PKDrawing 복원 실패: \(error.localizedDescription)")
        }
    }
    
    // 파일
//    func saveDrawingToFile() {
//        let drawing = canvas.drawing
//        let data = drawing.dataRepresentation()
////        guard let data = JSONManager.shared.encode(codable: drawing) else {
////            return
////        }
//        print(data.base64EncodedString())
//        let url = drawingFileURL()
//
//        do {
//            try data.write(to: url)
//            showCanvas = false
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
//
//    func loadDrawingFromFile() {
////        let pkDrawingString = "d3Jk8AEACAAS"
////
////        guard let data = Data(base64Encoded: pkDrawingString) else {
////            return
////        }
////
////        canvas.drawing = try! PKDrawing(data: data)
//
//
//        let url = drawingFileURL()
//
//        guard FileManager.default.fileExists(atPath: url.path) else {
//            return
//        }
//
//        do {
//            let data = try Data(contentsOf: url)
//            let drawing = try PKDrawing(data: data)
//            canvas.drawing = drawing
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
//
//    private func drawingFileURL() -> URL {
//        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        return directory.appendingPathComponent("drawing.pkdraw")
//    }
}
