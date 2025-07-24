//
//  DiaryCanvasView.swift
//  Divary
//
//  Created by 김나영 on 7/18/25.
//

import SwiftUI
import PencilKit

struct DiaryCanvasView: View {
    @ObservedObject var viewModel: DiaryCanvasViewModel

    var body: some View {
        ZStack(alignment: .bottom){
            canvasView
            drawingBar
                .padding(.bottom, canvasView.frame.height)
        }
        .onAppear {
            if let saved = UserDefaults.standard.string(forKey: "SavedDrawing") {
                viewModel.loadDrawingFromString(saved)
            }
//            viewModel.loadDrawingFromFile()
        }
    }
    
    private var canvasView: CanvasView {
        CanvasView(canvas: viewModel.canvas, toolPicker: viewModel.toolPicker)
    }
    
    private var drawingBar: some View {
        HStack(spacing: 12) {
            // 취소 버튼
            Button(action: { viewModel.dismissCanvas() }) {
                Text("취소")
                    .font(.NanumSquareNeo.NanumSquareNeoBold(size: 12))
                    .foregroundStyle(Color(.black))
            }
            .padding(.leading, 12)
            
            Spacer()
            
            // undo 버튼
            Button(action: { viewModel.undo() }) {
                Image("humbleicons_arrow_go_back")
                    .foregroundColor(viewModel.canUndo ? .black : Color(.G_500))
            }
            .padding(.trailing, 18)
            
            // redo 버튼
            Button(action: { viewModel.redo() }) {
                Image("humbleicons_arrow_go_forward")
                    .foregroundColor(viewModel.canRedo ? .black : Color(.G_500))
            }
            
            Spacer()
            
            // 저장 버튼
            Button(action: {
                viewModel.saveDrawingToFile()
                let base64 = viewModel.saveDrawingAsString()
                UserDefaults.standard.set(base64, forKey: "SavedDrawing")
                viewModel.dismissCanvas()
            }) {
                Image("humbleicons_check")
                    .foregroundColor(Color(.black))
            }
            .padding(.trailing, 12)
        }
        .padding(.vertical, 12)
        .background(Color(.G_100))
    }

}

struct CanvasView: UIViewRepresentable {
    let canvas: PKCanvasView
    let toolPicker: PKToolPicker
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvas.isOpaque = false
        
        toolPicker.setVisible(true, forFirstResponder: canvas)
        toolPicker.addObserver(canvas)
        canvas.becomeFirstResponder()
        
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
    
    var frame: CGRect {
        return toolPicker.frameObscured(in: canvas)
    }
}

#Preview {
    DiaryCanvasView(viewModel: DiaryCanvasViewModel(showCanvas: .constant(true)))
}
