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
    @State private var currentOffsetY: CGFloat = 0
    
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
//                    .overlay(
//                        showCanvas ? DiaryCanvasView(viewModel: DiaryCanvasViewModel(showCanvas: $showCanvas)) : nil
//                    )
            
                    .overlay(
                        showCanvas ? DiaryCanvasView(
                            viewModel: DiaryCanvasViewModel(showCanvas: $showCanvas),
                            offsetY: currentOffsetY
                        ) : nil
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
                .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height)
                
                if let drawing = viewModel.savedDrawing {
                    DrawingCanvasView(drawing: drawing)
                    
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .named("scroll")).origin.y)
                    }
                }
                
            }
            .task {
                viewModel.loadSavedDrawing()
            }
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            currentOffsetY = -value
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
