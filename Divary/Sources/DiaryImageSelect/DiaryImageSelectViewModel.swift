//
//  DiaryImageSelectViewModel.swift
//  Divary
//
//  Created by 김나영 on 7/8/25.
//

import Foundation
import SwiftUI

class DiaryImageSelectViewModel: ObservableObject {
    // 임시로 박아둔 이미지 셋
    let imageSet: [UIImage] = [UIImage(named: "testImage")!,
                             UIImage(named: "tempImage")!,
                             UIImage(named: "tempImage")!]
}
