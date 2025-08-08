//
//  Canvas.swift
//  Divary
//
//  Created by 김나영 on 7/30/25.
//

import Foundation
import SwiftUI
import PencilKit

struct CanvasView: UIViewRepresentable { // UIKit 에서 가져온 펜슬킷 실질적 캔버스뷰
    let canvas: PKCanvasView
    let toolPicker: PKToolPicker
    let offsetY: CGFloat
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvas.isOpaque = false
        
        toolPicker.setVisible(true, forFirstResponder: canvas)
        toolPicker.addObserver(canvas)
        canvas.becomeFirstResponder()
        
        DispatchQueue.main.async {
            canvas.contentOffset.y = offsetY
        }
        
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.contentOffset.y = offsetY
    }
    
    var frame: CGRect {
        return toolPicker.frameObscured(in: canvas)
    }
}
