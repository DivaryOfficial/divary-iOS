//
//  LocationSearchManager.swift
//  Divary
//
//  Created by 바견규 on 8/14/25.
//

import SwiftUI

// LocationSearchManager 클래스
class LocationSearchManager: ObservableObject {
    @Published var selectedLocation: String = ""
    @Published var isSearching: Bool = false
    
    func startSearch(currentValue: String = "") {
        selectedLocation = currentValue
        isSearching = true
    }
    
    func selectLocation(_ location: String) {
        selectedLocation = location
        isSearching = false
    }
}
