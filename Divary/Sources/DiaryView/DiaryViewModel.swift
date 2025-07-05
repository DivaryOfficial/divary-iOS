//
//  DiaryViewModel.swift
//  Divary
//
//  Created by 김나영 on 7/6/25.
//

import Foundation
import SwiftUI
import PhotosUI

class DiaryViewModel: ObservableObject {
    @Published var diaryText: String = ""
    @Published var selectedItems: [PhotosPickerItem] = []
}
