//
//  DiaryImageDecoView.swift
//  Divary
//
//  Created by 김나영 on 7/7/25.
//

import SwiftUI

struct DiaryImageDecoView: View {
    @StateObject var viewModel: DiaryImageDecoViewModel
    @State private var selectedFrameType: DiaryImageDecoViewModel.FrameType? = nil

    var body: some View {
        Spacer()
        frameSelectBar
    }
    
    private var frameSelectBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 25) {
                ZStack {
                    Rectangle()
                        .frame(width: 70, height: 85) // 높이 수정 필요
                        .foregroundStyle(Color(.G_300))
                    Text("없음")
                }
                ForEach(DiaryImageDecoViewModel.FrameType.allCases, id: \.self) { type in
                    Button {
                        selectedFrameType = type
                    } label: {
                        DiaryImageFrame(frameType: type, isSelected: false)
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
    DiaryImageDecoView(viewModel: DiaryImageDecoViewModel(frameType: .pastelBlue, isSelected: true))
}
