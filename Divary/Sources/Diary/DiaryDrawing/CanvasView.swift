//
//  Canvas.swift
//  Divary
//
//  Created by 김나영 on 7/30/25.
//

import Foundation
import SwiftUI
import PencilKit

struct CanvasView: UIViewRepresentable { // UIKit 에서 가져온 펜슬킷 캔버스뷰
    let canvas: PKCanvasView
    let toolPicker: PKToolPicker
    let offsetY: CGFloat

    @Binding var obscuredHeight: CGFloat

    private let minCanvasHeight: CGFloat = 20000

    // MARK: - Coordinator
    class Coordinator: NSObject, PKToolPickerObserver {
        var parent: CanvasView
        init(_ parent: CanvasView) { self.parent = parent }

        func toolPickerVisibilityDidChange(_ toolPicker: PKToolPicker) {
            updateObscuredHeight()
        }

        func toolPickerFramesObscuredDidChange(_ toolPicker: PKToolPicker) {
            updateObscuredHeight()
        }

        private func updateObscuredHeight() {
                let rect = self.parent.toolPicker.frameObscured(in: self.parent.canvas)
                let h = max(0, rect.height)
                if self.parent.obscuredHeight != h {
                    self.parent.obscuredHeight = h
                }
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> PKCanvasView {
        canvas.isOpaque = false

        toolPicker.setVisible(true, forFirstResponder: canvas)
        toolPicker.addObserver(canvas)
        toolPicker.addObserver(context.coordinator)
        canvas.becomeFirstResponder()

        DispatchQueue.main.async {
            if canvas.contentSize.height < minCanvasHeight {
                canvas.contentSize = CGSize(width: canvas.bounds.width, height: minCanvasHeight)
            }
            canvas.contentOffset.y = offsetY
            // 초기 한 번 바로 측정
            context.coordinator.toolPickerVisibilityDidChange(toolPicker)
        }
        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.contentOffset.y = offsetY
        // 회전/레이아웃 변경 시에도 최신 값 반영
        DispatchQueue.main.async {
            context.coordinator.toolPickerFramesObscuredDidChange(toolPicker)
        }
    }
}
