//
//  DiaryMainView.swift
//  Divary
//
//  Created by 김나영 on 7/6/25.
//

import SwiftUI
import PhotosUI
import PencilKit

struct DiaryMainView: View {
    @State var showCanvas: Bool = false
    
    @StateObject private var viewModel = DiaryMainViewModel()

    var body: some View {
        NavigationView {
//            ZStack {
                diaryMain
                    .toolbar {
                        ToolbarItemGroup(placement: .bottomBar) {
                            PhotosPicker(selection: $viewModel.selectedItems, matching: .images) {
                                Image(.photo)
                            }
                            Button(action: { }) {
                                Image(.font)
                            }
                            Button(action: { }) {
                                Image(.alignText)
                            }
                            Button(action: {  }) {
                                Image(.sticker)
                            }
                            Button(action: {
                                showCanvas = true
                            }) {
                                Image(.pencil)
                            }
                            Button(action: { }) {
                                Image(.keyboard)
                            }
                        }
                    }
                    .overlay(
                        showCanvas ? DiaryCanvasView(viewModel: DiaryCanvasViewModel(showCanvas: $showCanvas)) : nil
                    )

//                showCanvas ? DiaryCanvasView(viewModel: DiaryCanvasViewModel(showCanvas: $showCanvas)) : nil
//            }
        }
    }
    
    private var diaryMain: some View {
        ScrollView {
            ZStack {
                Image(.gridBackground)
                    .resizable(resizingMode: .tile)
//                    .resizable()
//                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack {
                    Group {
                        TextField("|", text: $viewModel.diaryText)
                            .foregroundColor(Color(.black))
                        Spacer()
                    }
                    .padding(.top, 44)
                    .padding(.leading, 45)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height * 2)
                
                if let drawing = viewModel.savedDrawing {
                    DiaryDrawingImageView(drawing: drawing)
                        .frame(height: 300) // 원하는 위치/크기
                        .offset(y: -500) // 스크롤뷰 내 위치 (고정값 or 변수화 가능)
                }
            }
            .onAppear {
                viewModel.loadSavedDrawing()
            }
        }
    }
}

#Preview {
    PreviewWrapper()
}

private struct PreviewWrapper: View {
    @State private var showCanvas = false

    var body: some View {
        DiaryMainView(showCanvas: showCanvas)
    }
}
