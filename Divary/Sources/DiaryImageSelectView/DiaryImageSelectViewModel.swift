//
//  DiaryImageSelectViewModel.swift
//  Divary
//
//  Created by 김나영 on 7/8/25.
//

import Foundation
import SwiftUI

class DiaryImageSelectViewModel: ObservableObject {
    @Published var showDeletePopup = false
    
//    init(imageSlideView: ImageSlideView) {
//        self.imageSlideView = imageSlideView
//    }
    
    // 임시로 박아둔 이미지 셋
    var imageSlideView = ImageSlideView(images: [
        UIImage(named: "testImage")!,
        UIImage(named: "tempImage")!,
        UIImage(named: "tempImage")!
    ])
    
    init() {
        a(a: 4)
    }
    
    
    private func a(a: Int = 3, b: Int = 4) {
        
    }
    
    
}
