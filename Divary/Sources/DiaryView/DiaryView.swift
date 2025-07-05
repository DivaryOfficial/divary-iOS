//
//  DiaryView.swift
//  Divary
//
//  Created by 김나영 on 7/6/25.
//

import SwiftUI
import PhotosUI

struct DiaryView: View {
    @StateObject private var viewModel = DiaryViewModel()

    var body: some View {
        diaryMain
        footerBar
    }
    
    private var diaryMain: some View {
        ZStack {
            Image("gridBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                Group {
                    TextField("|", text: $viewModel.diaryText)
                        .foregroundColor(Color("black"))
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
                Image("photo")
            }
            Image("font")
            Image("alignText")
            Image("sticker")
            Image("pencil")
            Spacer()
            Image("keyboardDown")
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .background(Color("G100"))
    }
}



#Preview {
    DiaryView()
}
