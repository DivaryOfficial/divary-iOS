//
//  DiaryImageDecoViewModel.swift
//  Divary
//
//  Created by 김나영 on 7/7/25.
//

import Foundation
import SwiftUI

class DecoViewModelStore: ObservableObject {
    @Published var viewModels: [DiaryImageDecoViewModel] = [
        DiaryImageDecoViewModel(frameType: .pastelPink, isSelected: true),
        DiaryImageDecoViewModel(frameType: .origin, isSelected: true)
    ]
}

class DiaryImageDecoViewModel: ObservableObject {
    @Published var showDeletePopup = false
    
    @Published var imageCaption: String = ""
    @Published var imageDate: String = "임시 날짜 2025.5.25 7:32"
    
    @Published var frameType: FrameType
    var isSelected: Bool
    
    init(frameType: FrameType, isSelected: Bool) {
        self.frameType = frameType
        self.isSelected = isSelected
    }
    
    enum FrameType: CaseIterable {
        case origin
        case white
        case ivory
        case pastelPink
        case pastelBlue
        case wood
        case black
        
        var frameColor: Color {
            switch self {
            case .origin:
                return .clear
            case .white:
                return Color(.white)
            case .ivory:
                return Color(.ivory)
            case .pastelPink:
                return Color(.pastelPink)
            case .pastelBlue:
                return Color(.pastelBlue)
            case .wood:
                return Color(.wood)
            case .black:
                return Color(.black)
            }
        }
        
        var innerCornerRadius: CGFloat {
            switch self {
            case .origin:
                return 0
            case .white:
                return 1.6
            case .ivory:
                return 1.6
            case .pastelPink:
                return 1.6
            case .pastelBlue:
                return 8
            case .wood:
                return 1.6
            case .black:
                return 1.6
            }
        }
    }
}
