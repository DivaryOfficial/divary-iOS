//
//  DiaryImageDecoView.swift
//  Divary
//
//  Created by 김나영 on 7/7/25.
//

import SwiftUI

struct DiaryImageDecoView: View {
    @StateObject var imageDecoViewModel = DiaryImageDecoViewModel(frameType: .pastelBlue, isSelected: true)
//    @StateObject var imageSelectViewModel = DiaryImageSelectViewModel()

    var body: some View {
        imageDecoratedGroup
        Spacer()
        frameSelectBar
    }
    
    private var imageDecoratedGroup: some View {
//        let _ = print("idg: \(imageDecoViewModel.frameType)")
        return DiaryImageFrame(viewModel: imageDecoViewModel)
            .padding(.top, 80)
    }
    
    private var frameSelectBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 25) {
                ForEach(DiaryImageDecoViewModel.FrameType.allCases, id: \.self) { type in
                    Button {
//                        print("나 눌림 \(type)")
                        imageDecoViewModel.frameType = type
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
    DiaryImageDecoView(imageDecoViewModel: DiaryImageDecoViewModel(frameType: .origin, isSelected: true))
}
