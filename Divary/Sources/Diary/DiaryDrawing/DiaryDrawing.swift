//
//  DiaryMainCanvasView.swift
//  Divary
//
//  Created by 김나영 on 7/30/25.
//

import Foundation
import SwiftUI
import PencilKit

struct DrawingCanvasView: UIViewRepresentable {
    let drawing: PKDrawing

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawing = drawing
        canvas.isUserInteractionEnabled = false // 읽기 전용
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.drawing = drawing
    }
}
