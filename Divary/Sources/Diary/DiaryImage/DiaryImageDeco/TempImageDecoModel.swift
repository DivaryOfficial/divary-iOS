////
////  DiaryImageDecoViewModel.swift
////  Divary
////
////  Created by 김나영 on 7/7/25.
////
//
//import Foundation
//import SwiftUI
//
//class DecoViewModelStore: ObservableObject {
//    @Published var viewModels: [TempImageDecoModel] = [
//        TempImageDecoModel(frameColor: .pastelPink, isSelected: true),
//        TempImageDecoModel(frameColor: .origin, isSelected: true)
//    ]
//}
//
//class TempImageDecoModel: ObservableObject {
//    @Published var showDeletePopup = false
//    
//    @Published var caption: String = ""
//    @Published var date: String = "임시 날짜 2025.5.25 7:32"
//    
//    @Published var frameColor: FrameColor
//    var isSelected: Bool
//    
//    init(frameColor: FrameColor, isSelected: Bool) {
//        self.frameColor = frameColor
//        self.isSelected = isSelected
//    }
//}
