//
//  DiaryMainView.swift
//  Divary
//
//  Created by 김나영 on 7/6/25.
//

import SwiftUI
import PhotosUI

struct DiaryMainView: View {
    @StateObject private var viewModel = DiaryMainViewModel()

    var body: some View {
        diaryMain
        footerBar
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



#Preview {
    DiaryMainView()
}
