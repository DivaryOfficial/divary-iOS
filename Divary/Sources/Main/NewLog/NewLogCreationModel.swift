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
    private let service = LogBookService.shared
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    
    // ✅ 중복 생성 방지를 위한 플래그
    private var isCreatingLog = false
    
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
        // ✅ 중복 호출 방지
        guard !isLoading else {
            completion(false)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        dataManager.checkLogExists(for: selectedDate) { result in
            self.isLoading = false
            
            switch result {
            case .success(let exists):
                if exists {
                    // 기존 로그가 있다면 캐시에서 찾아서 저장
                    self.existingLogBase = self.dataManager.findLogBase(for: self.selectedDate)
                }
                completion(exists)
                
            case .failure(let error):
                self.errorMessage = "로그 확인 중 오류가 발생했습니다: \(error.localizedDescription)"
                completion(false)
                print("❌ 로그 존재 확인 실패: \(error)")
            }
        }
    }
    
    // 다음 단계로
    func proceedToNextStep() {
        // ✅ 중복 호출 방지
        guard !isLoading else { return }
        
        checkLogExists { exists in
            if exists {
                self.currentStep = .existingLogConfirm
            } else {
                self.currentStep = .titleAndIcon
            }
        }
    }
    
    // ✅ 새 로그 생성 완료 (중복 방지 추가)
    func createNewLog(completion: @escaping (String?) -> Void) {
        // 중복 생성 방지
        guard !isCreatingLog else {
            print("⚠️ 이미 로그 생성 중이므로 요청 무시")
            completion(nil)
            return
        }
        
        guard let icon = selectedIcon else {
            completion(nil)
            return
        }
        
        // 중복 생성 방지 플래그 설정
        isCreatingLog = true
        isLoading = true
        errorMessage = nil
        
        print("🚀 새 로그 생성 시작: \(selectedTitle), 날짜: \(selectedDate)")
        
        dataManager.createLogBase(
            iconType: icon,
            name: selectedTitle,
            date: selectedDate
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.isCreatingLog = false // 완료 후 플래그 해제
                
                switch result {
                case .success(let logBaseId):
                    print("✅ 새 로그 생성 완료: logBaseId=\(logBaseId)")
                    completion(logBaseId)
                    
                case .failure(let error):
                    self?.errorMessage = "로그 생성 중 오류가 발생했습니다: \(error.localizedDescription)"
                    print("❌ 로그 생성 실패: \(error)")
                    completion(nil)
                }
            }
        }
    }
    
    // 기존 로그베이스 ID 반환
    func getExistingLogBaseId() -> String? {
        return existingLogBase?.id
    }
    
    // 데이터 리셋
    func resetData() {
        // ✅ 진행 중인 작업이 있으면 리셋하지 않음
        guard !isCreatingLog else {
            print("⚠️ 로그 생성 중이므로 리셋 무시")
            return
        }
        
        selectedDate = Date()
        selectedTitle = ""
        selectedIcon = nil
        currentStep = .calendar
        showNewLogCreation = false
        existingLogBase = nil
        errorMessage = nil
        isLoading = false
        isCreatingLog = false
        
        print("🔄 NewLogCreationViewModel 데이터 리셋 완료")
    }
    
    // 에러 메시지 클리어
    func clearError() {
        errorMessage = nil
    }
}
