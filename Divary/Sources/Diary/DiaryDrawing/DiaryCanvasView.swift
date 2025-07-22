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
            CanvasView(canvas: viewModel.canvas, toolPicker: viewModel.toolPicker)
            drawingBar
//                .padding(.bottom, 25)
                .padding(.bottom, 100)
        }
//        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            viewModel.loadDrawingFromFile()
        }
    }
    
    private var drawingBar: some View {
        HStack(spacing: 12) {
            Button(action: { viewModel.dismissCanvas() }) {
                Text("취소")
                    .font(.NanumSquareNeo.NanumSquareNeoBold(size: 12))
                    .foregroundStyle(Color(.black))
            }
            .padding(.leading, 12)
            
            Spacer()
            
            Button(action: { viewModel.undo() }) {
                Image("humbleicons_arrow_go_back")
                    .foregroundColor(viewModel.canUndo ? .black : Color(.G_500))
            }
            .padding(.trailing, 18)
            
            Button(action: { viewModel.redo() }) {
                Image("humbleicons_arrow_go_forward")
                    .foregroundColor(viewModel.canRedo ? .black : Color(.G_500))
            }
            
            Spacer()
            
            Button(action: {
                viewModel.saveDrawingToFile()
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
//        canvas.backgroundColor = .black.withAlphaComponent(0.5)
        
        toolPicker.setVisible(true, forFirstResponder: canvas)
        toolPicker.addObserver(canvas)
        canvas.becomeFirstResponder()
        
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}

#Preview {
    DiaryCanvasView(viewModel: DiaryCanvasViewModel(showCanvas: .constant(true)))
}
