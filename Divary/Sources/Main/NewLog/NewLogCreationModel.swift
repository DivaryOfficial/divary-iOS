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

//
//  NewLogCreationViewModel.swift - 수정
//  API 호출로 변경
//

@Observable
class NewLogCreationViewModel {
    var currentStep: NewLogCreationStep = .calendar
    var selectedDate: Date = Date()
    var selectedTitle: String = ""
    var selectedIcon: IconType? = nil
    var showNewLogCreation: Bool = false
    var isLoading: Bool = false
    
    private let dataManager = LogBookDataManager.shared
    
    // 기존 로그가 있는지 확인 (비동기)
    func checkExistingLog() async -> Bool {
        isLoading = true
        let exists = await dataManager.hasExistingLog(for: selectedDate)
        await MainActor.run {
            self.isLoading = false
        }
        return exists
    }
    
    // 기존 로그 찾기
    func findExistingLog(for date: Date) -> LogBookBase? {
        return dataManager.findLogBase(for: date)
    }
    
    // 다음 단계로 (비동기 확인 포함)
    func proceedToNextStep() async {
        let hasExisting = await checkExistingLog()
        await MainActor.run {
            if hasExisting {
                self.currentStep = .existingLogConfirm
            } else {
                self.currentStep = .titleAndIcon
            }
        }
    }
    
    // 새 로그 생성 완료 (비동기)
    func createNewLog() async -> String? {
        guard let icon = selectedIcon else { return nil }
        
        isLoading = true
        let newLogBaseId = await dataManager.createNewLog(
            date: selectedDate,
            title: selectedTitle,
            iconType: icon
        )
        
        await MainActor.run {
            self.isLoading = false
            if newLogBaseId != nil {
                self.resetData()
            }
        }
        
        return newLogBaseId
    }
    
    // 데이터 리셋
    func resetData() {
        selectedDate = Date()
        selectedTitle = ""
        selectedIcon = nil
        currentStep = .calendar
        showNewLogCreation = false
        isLoading = false
    }
}
