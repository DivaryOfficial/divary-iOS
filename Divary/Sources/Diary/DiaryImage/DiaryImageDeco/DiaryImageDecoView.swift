////
////  DiaryImageDecoView.swift
////  Divary
////
////  Created by 김나영 on 7/7/25.
////
//
//import SwiftUI
//
//struct DiaryImageDecoView: View {
//    @StateObject var store = DecoViewModelStore()
//    
//    @State private var showDeletePopup = false
//    @State private var currentIndex = 0
//
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            VStack {
//                headerBar
//                Spacer()
//                imageDecoratedGroup
//                Spacer()
//                frameSelectBar
//            }
//            
//            if showDeletePopup {
//                DeletePopupView(isPresented: $showDeletePopup, deleteText: "지금 돌아가면 변경 내용이 모두 삭제됩니다.")
//            }
//        }
//    }
//    
//    private var imageDecoratedGroup: some View {
//        ImageSlideView(framedImages: store.viewModels, isSelectView: false, currentIndex: $currentIndex)
//    }
//    
//    private var headerBar: some View {
//        HStack {
//            Button(action: { showDeletePopup = true }) {
//                Image(.close)
//            }
//            Spacer()
//            Button(action: { }) {
//                Image(.check)
//            }
//        }
//        .padding(.horizontal, 20)
//    }
//    
//    private var frameSelectBar: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack {
//                ForEach(FrameColor.allCases, id: \.self) { type in
//                    Button {
//                        if store.viewModels.indices.contains(currentIndex) {
//                            store.viewModels[currentIndex].frameColor = type
//                        }
//                    } label: {
//                        DiaryImageFrame(frameType: type)
//                    }
//                    .padding(.horizontal, 8)
//                    .padding(.vertical)
//                }
//            }
//        }
//        .background(Color(.G_100))
//    }
//}
//
//#Preview {
//    DiaryImageDecoView()
//}
