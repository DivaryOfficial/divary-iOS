//
//  DiaryCanvasView.swift
//  Divary
//
//  Created by 김나영 on 7/18/25.
//

import SwiftUI
import PencilKit

struct DiaryCanvasView: View {
    let canvas = PKCanvasView()
    let toolPicker = PKToolPicker()

//    @State private var showToolPicker: Bool = true
    @Binding var showCanvas: Bool

    var body: some View {
        VStack {
            drawingbar
            Spacer()
            CanvasView(canvas: canvas, toolPicker: toolPicker)
        }
    }
    
    private var drawingbar: some View {
        HStack {
            Button(action: { toolPickerToggle() }) {
                Text("취소")
            }
            Button(action: { }) {
                Text("이전")
            }
            Button(action: { }) {
                Text("다음")
            }
            Button(action: { }) {
                Text("저장")
            }
        }
    }

    private func toolPickerToggle() {
        toolPicker.setVisible(!toolPicker.isVisible, forFirstResponder: canvas)
        
//        showToolPicker.toggle()
        showCanvas.toggle()
    }
}

struct CanvasView: UIViewRepresentable {
    let canvas: PKCanvasView
    let toolPicker: PKToolPicker
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvas.isOpaque = false
        canvas.backgroundColor = .black.withAlphaComponent(0.5)
        
        toolPicker.setVisible(true, forFirstResponder: canvas)
        toolPicker.addObserver(canvas)
        canvas.becomeFirstResponder()
        
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}

#Preview {
    PreviewWrapper()
}

private struct PreviewWrapper: View {
    @State private var showCanvas = false

    var body: some View {
        DiaryCanvasView(showCanvas: $showCanvas)
    }
}
