//
//  DiaryImageDecoView.swift
//  Divary
//
//  Created by 김나영 on 7/7/25.
//

import SwiftUI

struct DiaryImageDecoView: View {
    @StateObject var store = DecoViewModelStore()
    
    @State private var showDeletePopup = false
    @State private var currentIndex = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                headerBar
                Spacer()
                imageDecoratedGroup
                Spacer()
                frameSelectBar
            }
            
            if showDeletePopup {
                DeletePopupView(isPresented: $showDeletePopup, deleteText: "지금 돌아가면 변경 내용이 모두 삭제됩니다.")
            }
        }
    }
    
    private var imageDecoratedGroup: some View {
        ImageSlideView(framedImages: store.viewModels, isSelectView: false, currentIndex: $currentIndex)
    }
    
    private var headerBar: some View {
        HStack {
            Button(action: { showDeletePopup = true }) {
                Image("iconamoon_close-thin")
                    .foregroundStyle(Color(.black))
            }
            Spacer()
            Button(action: { }) {
                Image("humbleicons_check")
                    .foregroundStyle(Color(.black))
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var frameSelectBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 25) {
                ForEach(DiaryImageDecoViewModel.FrameType.allCases, id: \.self) { type in
                    Button {
                        if store.viewModels.indices.contains(currentIndex) {
                            store.viewModels[currentIndex].frameType = type
                        }
                    } label: {
                        DiaryImageFrame(frameType: type)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(.G_100))
    }
}

#Preview {
    DiaryImageDecoView()
}
