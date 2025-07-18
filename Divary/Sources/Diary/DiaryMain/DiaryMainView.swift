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
    let canvas = PKCanvasView()
    let toolPicker = PKToolPicker()
    @State var showCanvas: Bool = false
    
    @StateObject private var viewModel = DiaryMainViewModel()

    var body: some View {
        NavigationView {
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
                    showCanvas ? DiaryCanvasView(showCanvas: $showCanvas) : nil
                )
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
    
    private var footerBar: some View {
        HStack (spacing: 20){
            PhotosPicker(selection: $viewModel.selectedItems, matching: .images) {
                Image(.photo)
            }
            Image(.font)
            Image(.alignText)
            Image(.sticker)
            Image(.pencil)
            Spacer()
            Image(.keyboardDown) // 키보드 내려가있을 땐 키보드 올리기 버튼으로 보이게 수정해야함
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .background(Color(.G_100))
    }
}



//#Preview {
//    DiaryMainView()
//}

#Preview {
    PreviewWrapper()
}

private struct PreviewWrapper: View {
    @State private var showCanvas = false

    var body: some View {
        DiaryMainView(showCanvas: showCanvas)
    }
}
