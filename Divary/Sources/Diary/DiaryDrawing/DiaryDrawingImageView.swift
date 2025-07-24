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
            Text("빈 그림입니다")
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    let path = PKStrokePath(controlPoints: [
        PKStrokePoint(location: CGPoint(x: 0, y: 0), timeOffset: 0, size: CGSize(width: 5, height: 5), opacity: 1, force: 1, azimuth: 0, altitude: 0),
        PKStrokePoint(location: CGPoint(x: 100, y: 100), timeOffset: 0.1, size: CGSize(width: 5, height: 5), opacity: 1, force: 1, azimuth: 0, altitude: 0)
    ], creationDate: Date())

    let ink = PKInk(.pen, color: .black)
    let stroke = PKStroke(ink: ink, path: path)
    let drawing = PKDrawing(strokes: [stroke])
    
    return DiaryDrawingImageView(drawing: drawing)
}

