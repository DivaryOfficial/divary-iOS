//
//  NewLogCreationModel.swift
//  Divary
//
//  Created by chohaeun on 8/5/25.
//

// NewLogCreationModels.swift

import Foundation
import SwiftUI

// 새 로그 생성 단계
enum NewLogCreationStep {
    case calendar
    case existingLogConfirm
    case titleAndIcon
}

// 새 로그 생성 뷰모델
@Observable
class NewLogCreationViewModel {
    var currentStep: NewLogCreationStep = .calendar
    var selectedDate: Date = Date()
    var selectedTitle: String = ""
    var selectedIcon: IconType? = nil
    var showNewLogCreation: Bool = false
    
    // MockDataManager 사용
    private let dataManager = MockDataManager.shared
    
    // 기존 로그가 있는지 확인
    func hasExistingLog(for date: Date) -> Bool {
        return dataManager.hasExistingLog(for: date)
    }
    
    // 기존 로그 찾기
    func findExistingLog(for date: Date) -> LogBookBaseMock? {
        return dataManager.findLogBase(for: date)
    }
    
    // 다음 단계로
    func proceedToNextStep() {
        if hasExistingLog(for: selectedDate) {
            currentStep = .existingLogConfirm
        } else {
            currentStep = .titleAndIcon
        }
    }
    
    // 새 로그 생성 완료
    func createNewLog() -> String {
        guard let icon = selectedIcon else { return "" }
        
        // MockDataManager에 새 로그베이스 추가
        let newLogBaseId = dataManager.addNewLogBase(
            date: selectedDate,
            title: selectedTitle,
            iconType: icon
        )
        
        print("새 로그 생성: ID=\(newLogBaseId), 날짜=\(selectedDate), 제목=\(selectedTitle), 아이콘=\(icon.rawValue)")
        
        resetData()
        return newLogBaseId
    }
    
    // 데이터 리셋
    func resetData() {
        selectedDate = Date()
        selectedTitle = ""
        selectedIcon = nil
        currentStep = .calendar
        showNewLogCreation = false
    }
}
