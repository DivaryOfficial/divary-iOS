//
//  DrawingCanvasView.swift
//  Divary
//
//  Created by 김나영 on 7/30/25.
//

import Foundation
import SwiftUI
import PencilKit

struct DrawingScreenView: UIViewRepresentable { // 그렸던 그림 띄워주는 뷰 (그리기 불가, 보여주기용)
    let drawing: PKDrawing
    let offsetY: CGFloat

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawing = drawing
        canvas.isUserInteractionEnabled = false // 읽기 전용
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.contentOffset.y = offsetY
        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.drawing = drawing
    }
}
