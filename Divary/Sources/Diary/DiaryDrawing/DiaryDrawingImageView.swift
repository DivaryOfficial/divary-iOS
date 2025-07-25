//
//  DiaryDrawingImageView.swift
//  Divary
//
//  Created by 김나영 on 7/25/25.
//

import SwiftUI
import PencilKit

struct DiaryDrawingImageView: View {
    let drawing: PKDrawing
    
    var body: some View {
        if !drawing.bounds.isNull {
            let image = drawing.image(from: drawing.bounds, scale: UIScreen.main.scale)
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        } else {
            Text("빈 그림")
                .foregroundColor(.gray)
        }
    }
}
