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
    
    // API 연동 관련
    private let dataManager = LogBookDataManager.shared
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    
    // 존재하는 로그 정보
    private var existingLogBase: LogBookBase?
    
    // 기존 로그가 있는지 확인 (API 호출)
    func hasExistingLog(for date: Date) -> Bool {
        // 먼저 캐시에서 확인
        return dataManager.hasExistingLog(for: date)
    }
    
    // 기존 로그 찾기 (캐시에서)
    func findExistingLog(for date: Date) -> LogBookBase? {
        return dataManager.findLogBase(for: date)
    }
    
    // 선택된 날짜에 로그 존재 여부 확인 (API 호출)
    func checkLogExists(completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        dataManager.checkLogExists(for: selectedDate) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let exists):
                    if exists {
                        // 기존 로그가 있다면 캐시에서 찾아서 저장
                        self?.existingLogBase = self?.dataManager.findLogBase(for: self?.selectedDate ?? Date())
                    }
                    completion(exists)
                    
                case .failure(let error):
                    self?.errorMessage = "로그 확인 중 오류가 발생했습니다: \(error.localizedDescription)"
                    completion(false)
                    print("❌ 로그 존재 확인 실패: \(error)")
                }
            }
        }
    }
    
    // 다음 단계로
    func proceedToNextStep() {
        checkLogExists { [weak self] exists in
            DispatchQueue.main.async {
                if exists {
                    self?.currentStep = .existingLogConfirm
                } else {
                    self?.currentStep = .titleAndIcon
                }
            }
        }
    }
    
    // 새 로그 생성 완료
    func createNewLog(completion: @escaping (String?) -> Void) {
        guard let icon = selectedIcon else {
            completion(nil)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        dataManager.createLogBase(
            iconType: icon,
            name: selectedTitle,
            date: selectedDate
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let logBaseId):
                    print("✅ 새 로그 생성 성공: ID=\(logBaseId)")
                    self?.resetData()
                    completion(logBaseId)
                    
                case .failure(let error):
                    self?.errorMessage = "로그 생성 중 오류가 발생했습니다: \(error.localizedDescription)"
                    print("❌ 새 로그 생성 실패: \(error)")
                    completion(nil)
                }
            }
        }
    }
    
    // 새 로그 생성 완료 (기존 메서드 호환성 유지)
    func createNewLog() -> String {
        guard let icon = selectedIcon else { return "" }
        
        // 비동기 메서드를 동기적으로 처리하기 위한 임시 방법
        // 실제로는 completion handler 버전을 사용하는 것이 좋습니다
        var result = ""
        let semaphore = DispatchSemaphore(value: 0)
        
        createNewLog { logBaseId in
            result = logBaseId ?? ""
            semaphore.signal()
        }
        
        semaphore.wait()
        return result
    }
    
    // 기존 로그베이스 ID 반환
    func getExistingLogBaseId() -> String? {
        return existingLogBase?.id
    }
    
    // 데이터 리셋
    func resetData() {
        selectedDate = Date()
        selectedTitle = ""
        selectedIcon = nil
        currentStep = .calendar
        showNewLogCreation = false
        existingLogBase = nil
        errorMessage = nil
        isLoading = false
    }
    
    // 에러 메시지 클리어
    func clearError() {
        errorMessage = nil
    }
}
