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
    let offsetY: CGFloat

    var body: some View {
        ZStack(alignment: .bottom){
            canvasView
            drawingBar
                .padding(.bottom, canvasView.frame.height)
        }
        .onAppear {
            if let data = UserDefaults.standard.data(forKey: "SavedDrawingMeta"),
               let meta = try? JSONDecoder().decode(DrawingMeta.self, from: data) {
                viewModel.loadDrawingFromString(meta.base64)
            }
            
//            if let saved = UserDefaults.standard.string(forKey: "SavedDrawing") {
//                viewModel.loadDrawingFromString(saved)
//            }
            
//            viewModel.loadDrawingFromFile()
        }
    }
    
    private var canvasView: CanvasView {
        CanvasView(canvas: viewModel.canvas, toolPicker: viewModel.toolPicker, offsetY: offsetY)
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
                Image("humbleicons_arrow-go-back")
                    .foregroundColor(viewModel.canUndo ? .black : Color(.G_500))
            }
            .padding(.trailing, 18)
            
            // redo 버튼
            Button(action: { viewModel.redo() }) {
                Image("humbleicons_arrow-go-forward")
                    .foregroundColor(viewModel.canRedo ? .black : Color(.G_500))
            }
            
            Spacer()
            
            // 저장 버튼
            Button(action: {
//                viewModel.saveDrawingToFile()
                
//                let base64 = viewModel.saveDrawingAsString()
//                UserDefaults.standard.set(base64, forKey: "SavedDrawing")
                
                viewModel.saveDrawingWithOffset(offsetY: offsetY)
                
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

#Preview {
    DiaryCanvasView(
        viewModel: DiaryCanvasViewModel(showCanvas: .constant(true)),
        offsetY: 300
    )
}

