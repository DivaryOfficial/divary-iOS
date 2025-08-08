//
//  DiaryCanvasView.swift
//  Divary
//
//  Created by 김나영 on 7/18/25.
//

import SwiftUI
import PencilKit

struct DiaryCanvasView: View { // 그리는 공간
    @ObservedObject var viewModel: DiaryCanvasViewModel
    let offsetY: CGFloat
    var onSaved: ((PKDrawing, CGFloat) -> Void)?    // ← 추가

    var body: some View {
        ZStack(alignment: .bottom){
            canvasView
            drawingBar
                .padding(.bottom, canvasView.frame.height)
        }
        .task {
            viewModel.loadDrawingIfExists()
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
                
                viewModel.saveDrawingWithOffset(offsetY: offsetY)
                onSaved?(viewModel.canvas.drawing, offsetY)
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
        viewModel: DiaryCanvasViewModel(showCanvas: .constant(true), diaryId: 0),
        offsetY: 0
    )
}

