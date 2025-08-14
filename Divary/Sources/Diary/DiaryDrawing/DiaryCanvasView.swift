//
//  DiaryCanvasView.swift
//  Divary
//
//  Created by 김나영 on 7/18/25.
//

import SwiftUI
import PencilKit
import UIKit

struct DiaryCanvasView: View { // 일기메인뷰에서 연필 버튼 누르면 뜨는 그리는 공간 (CanvasView를 사용)
    @ObservedObject var viewModel: DiaryCanvasViewModel
    let offsetY: CGFloat
    let initialDrawing: PKDrawing?
    var onSaved: ((PKDrawing, CGFloat) -> Void)?
    
    // 기기 판별
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    var body: some View {
        ZStack(alignment: .bottom){
            canvasView
        }
        // iPad는 상단, iPhone은 하단에 배치
        .overlay(alignment: isPad ? .top : .bottom) {
            drawingBar
                // iPhone에서는 PencilKit 툴피커가 가리는 높이만큼 여백 유지
                .padding(isPad ? .top : .bottom, isPad ? 0 : canvasView.frame.height)
        }
        .task {
//            viewModel.loadDrawingIfExists()
            if let d = initialDrawing {
                viewModel.canvas.drawing = d // 서버에서 받은 기존 그림 주입
            } else {
                viewModel.loadDrawingIfExists() // 폴백: 로컬
            }
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
            
            if !isPad {
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
            }
//            // undo 버튼
//            Button(action: { viewModel.undo() }) {
//                Image("humbleicons_arrow-go-back")
//                    .foregroundColor(viewModel.canUndo ? .black : Color(.G_500))
//            }
//            .padding(.trailing, 18)
//            
//            // redo 버튼
//            Button(action: { viewModel.redo() }) {
//                Image("humbleicons_arrow-go-forward")
//                    .foregroundColor(viewModel.canRedo ? .black : Color(.G_500))
//            }
            
            Spacer()
            
            // 저장 버튼
            Button(action: {
//                viewModel.saveDrawingWithOffset(offsetY: offsetY)
//                onSaved?(viewModel.canvas.drawing, offsetY)
                onSaved?(viewModel.canvas.drawing, viewModel.canvas.contentOffset.y)
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
//    DiaryCanvasView(
//        viewModel: DiaryCanvasViewModel(showCanvas: .constant(true), diaryId: 0),
//        offsetY: 0
//    )
}

