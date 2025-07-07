//
//  DiaryImageDecoView.swift
//  Divary
//
//  Created by 김나영 on 7/7/25.
//

import SwiftUI

struct DiaryImageDecoView: View {
    var body: some View {
        Spacer()
        frameSelectBar
    }
    
    private var frameSelectBar: some View {
        DiaryImageFrame(frameType: .pastelBlue, isSelected: false)
    }
}

#Preview {
    DiaryImageDecoView()
}
