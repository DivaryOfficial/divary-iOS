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
    @State private var savedDrawing: PKDrawing? = nil
    
    @StateObject private var viewModel = DiaryMainViewModel()

    var body: some View {
        NavigationView {
            ZStack {
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
                showCanvas ? DiaryCanvasView(viewModel: DiaryCanvasViewModel(showCanvas: $showCanvas)) : nil
            }
        }
    }
    
    private var diaryMain: some View {
        ZStack {
            Image(.gridBackground)
                .resizable()
                .scaledToFill()
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
