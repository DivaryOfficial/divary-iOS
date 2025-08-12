//
//  LogBookMainViewModel.swift
//  Divary
//
//  Created by 바견규 on 7/17/25.
//

import SwiftUI

@Observable
class LogBookMainViewModel {
    var diveLogData: [DiveLogData] = []
    var selectedDate = Date()
    var logBaseId: String
    var logBaseInfoId: Int
    var logBaseTitle: String = ""
    var isTempSaved: Bool = false
    var tempSavedData: [DiveLogData] = []
    
    // 저장 관련 상태
    var showSavePopup = false
    var showSavedMessage = false
    
    // API 연동 관련
    private let dataManager = LogBookDataManager.shared
    private let service = LogBookService.shared
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    
    var logCount: Int {
        diveLogData.filter { !$0.isEmpty }.count
    }
    
    // 계산된 프로퍼티명을 다른 이름으로 변경
    var displayTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return "\(formatter.string(from: selectedDate)) \(logBaseTitle)"
    }
    
    // 기존 init (기본값용)
     init() {
         self.logBaseId = ""
         self.logBaseInfoId = 0
         self.diveLogData = [] // 빈 배열로 시작
         self.logBaseTitle = "다이빙 로그북"
         self.tempSavedData = []
     }
     
     // logBaseId를 받는 init
     init(logBaseId: String) {
         self.logBaseId = logBaseId
         self.logBaseInfoId = Int(logBaseId) ?? 0
         self.diveLogData = [] // 빈 배열로 시작
         self.tempSavedData = []
         
         // 초기 데이터 로드
         loadLogBaseDetail()
     }
    
    // MARK: - API 연동 메서드
    
    // 로그베이스 상세 데이터 로드
    func loadLogBaseDetail() {
        isLoading = true
        errorMessage = nil
        
        dataManager.fetchLogBaseDetail(logBaseInfoId: logBaseInfoId) { result in
            self.isLoading = false
            
            switch result {
            case .success(let logBase):
                self.updateFromLogBase(logBase)
                
            case .failure(let error):
                self.errorMessage = "로그 데이터를 불러올 수 없습니다: \(error.localizedDescription)"
                print("❌ 로그베이스 상세 조회 실패: \(error)")
            }
        }
    }
    
    // LogBase 데이터로 ViewModel 업데이트
    private func updateFromLogBase(_ logBase: LogBookBase) {
        selectedDate = logBase.date
        logBaseTitle = logBase.title
        
        // 로그북 데이터 업데이트 (동적 개수)
        diveLogData = []
        
        for logBook in logBase.logBooks {
            let logData = logBook.diveData
            logData.logBookId = logBook.logBookId
            logData.saveStatus = logBook.saveStatus
            diveLogData.append(logData)
            
            // 임시저장 상태 확인
            if logBook.saveStatus == .temp {
                isTempSaved = true
            }
        }
        
        // ✅ 로그북이 없으면 첫 번째 로그북 자동 생성 (기존 로직 제거)
        // 이제 로그베이스 생성 시 자동으로 빈 로그북 1개가 생성되므로 여기서 별도 생성 불필요
        if diveLogData.isEmpty {
            // 빈 데이터라도 일단 하나 추가하여 UI가 정상 동작하도록 함
            let emptyLogData = DiveLogData()
            diveLogData.append(emptyLogData)
        }
        
        // 임시저장 데이터 백업
        updateTempSavedDataArray()
        
        print("✅ LogBase 업데이트 완료 - 로그북 개수: \(diveLogData.count)")
    }
    
    // 임시저장 데이터 배열 업데이트
    private func updateTempSavedDataArray() {
        tempSavedData = diveLogData.map { data in
            copyDiveLogData(data)
        }
    }
    
    // ✅ 새 로그북 추가 (슬라이드 시 사용 - DataManager의 addNewLogBook 호출)
    func addNewLogBook(completion: @escaping (Bool) -> Void) {
        guard diveLogData.count < 3 else {
            completion(false)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // DataManager의 addNewLogBook 메서드 사용
        dataManager.addNewLogBook(logBaseInfoId: logBaseInfoId) { result in
            self.isLoading = false
            
            switch result {
            case .success(let logBookId):
                // 새 로그북 데이터 추가
                let newLogData = DiveLogData()
                newLogData.logBookId = logBookId
                newLogData.saveStatus = .temp
                
                self.diveLogData.append(newLogData)
                self.tempSavedData.append(DiveLogData())
                
                completion(true)
                print("✅ 새 로그북 추가 성공: logBookId=\(logBookId)")
                
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                completion(false)
                print("❌ 새 로그북 추가 실패: \(error)")
            }
        }
    }
    
    // 개별 로그북 저장
    func saveLogBook(at index: Int, saveStatus: SaveStatus, completion: @escaping (Bool) -> Void) {
        guard index < diveLogData.count,
              let logBookId = diveLogData[index].logBookId else {
            completion(false)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let logUpdateRequest = diveLogData[index].toLogUpdateRequest(
            with: selectedDate,
            saveStatus: saveStatus
        )
        
        service.updateLogBook(logBookId: logBookId, logData: logUpdateRequest) { result in
            self.isLoading = false
            
            switch result {
            case .success:
                // 저장 상태 업데이트
                self.diveLogData[index].saveStatus = saveStatus
                
                if saveStatus == .temp {
                    self.isTempSaved = true
                } else {
                    // 완전저장 시 임시저장 상태 해제
                    self.isTempSaved = false
                }
                
                completion(true)
                print("✅ 로그북 저장 성공: logBookId=\(logBookId)")
                
            case .failure(let error):
                self.errorMessage = "저장 중 오류가 발생했습니다: \(error.localizedDescription)"
                completion(false)
                print("❌ 로그북 저장 실패: \(error)")
            }
        }
    }
    
    // MARK: - 저장 관련 메서드
    
    // 저장 버튼 처리
    func handleSaveButtonTap() {
        if areAllSectionsCompleteForAllPages() {
            handleCompleteSave()
        } else {
            showSavePopup = true
        }
    }
    
    // 작성 완료하기 (완전 저장)
    func handleCompleteSave() {
        var completedCount = 0
        let totalSaves = diveLogData.filter { !$0.isEmpty }.count
        
        guard totalSaves > 0 else {
            showSavedMessage = true
            return
        }
        
        for (index, data) in diveLogData.enumerated() {
            if !data.isEmpty {
                saveLogBook(at: index, saveStatus: .complete) { success in
                    if success {
                        completedCount += 1
                        if completedCount == totalSaves {
                            self.showSavedMessage = true
                            self.showSavePopup = false
                        }
                    }
                }
            }
        }
    }
    
    // 임시 저장하기 (SavePop에서 호출)
    func handleTempSaveFromSavePopup() {
        tempSave()
        
        withAnimation {
            showSavePopup = false
        }
    }
    
    // 임시저장
    func tempSave() {
        var completedCount = 0
        let totalSaves = diveLogData.filter { !$0.isEmpty }.count
        
        guard totalSaves > 0 else {
            isTempSaved = true
            return
        }
        
        for (index, data) in diveLogData.enumerated() {
            if !data.isEmpty {
                saveLogBook(at: index, saveStatus: .temp) { success in
                    if success {
                        completedCount += 1
                        if completedCount == totalSaves {
                            self.updateTempSavedData()
                        }
                    }
                }
            }
        }
    }
    
    // 임시저장 데이터 백업 업데이트
    private func updateTempSavedData() {
        updateTempSavedDataArray()
        isTempSaved = true
    }
    
    // MARK: - 기존 메서드들 (UI 호환성 유지)
    
    // 모든 페이지의 모든 섹션이 완성되었는지 확인
    private func areAllSectionsCompleteForAllPages() -> Bool {
        for (index, _) in diveLogData.enumerated() {
            if !areAllSectionsComplete(for: index) {
                return false
            }
        }
        return true
    }
    
    // 모든 섹션이 완성되었는지 체크
    func areAllSectionsComplete(for index: Int) -> Bool {
        guard index < diveLogData.count else { return false }
        
        let data = diveLogData[index]
        let sections: [InputSectionType] = [.overview, .participants, .equipment, .environment, .profile]
        
        return sections.allSatisfy { section in
            getSectionStatus(for: data, section: section) == .complete
        }
    }
    
    // 섹션별 상태 가져오기
    private func getSectionStatus(for data: DiveLogData, section: InputSectionType) -> SectionStatus {
        switch section {
        case .overview:
            return DiveOverviewSection.getStatus(overview: data.overview, isSaved: false)
        case .participants:
            return DiveParticipantsSection.getStatus(participants: data.participants, isSaved: false)
        case .equipment:
            return DiveEquipmentSection.getStatus(equipment: data.equipment, isSaved: false)
        case .environment:
            return DiveEnvironmentSection.getStatus(environment: data.environment, isSaved: false)
        case .profile:
            return DiveProfileSection.getStatus(profile: data.profile, isSaved: false)
        }
    }
    
    // 임시저장 후 변경사항이 있는지 체크
    func hasChangesFromTempSave(for index: Int) -> Bool {
        guard index < diveLogData.count && index < tempSavedData.count else { return false }
        
        let current = diveLogData[index]
        let tempSaved = tempSavedData[index]
        
        return !areDataEqual(current, tempSaved)
    }
    
    // 두 DiveLogData가 같은지 비교
    private func areDataEqual(_ data1: DiveLogData, _ data2: DiveLogData) -> Bool {
        return areOverviewEqual(data1.overview, data2.overview) &&
               areParticipantsEqual(data1.participants, data2.participants) &&
               areEquipmentEqual(data1.equipment, data2.equipment) &&
               areEnvironmentEqual(data1.environment, data2.environment) &&
               areProfileEqual(data1.profile, data2.profile)
    }
    
    // 현재 페이지의 모든 필드 초기화
    func clearAllFields(for index: Int) {
        guard index < diveLogData.count else { return }
        
        let logBookId = diveLogData[index].logBookId
        diveLogData[index] = DiveLogData()
        diveLogData[index].logBookId = logBookId
        
        if index < tempSavedData.count {
            tempSavedData[index] = DiveLogData()
            tempSavedData[index].logBookId = logBookId
        }
    }
    
    // 임시저장된 데이터로 되돌리기
    func restoreFromTempSave(for index: Int) {
        guard index < diveLogData.count && index < tempSavedData.count else { return }
        
        diveLogData[index] = copyDiveLogData(tempSavedData[index])
    }
    
    // DiveLogData 깊은 복사
    private func copyDiveLogData(_ data: DiveLogData) -> DiveLogData {
        let newData = DiveLogData()
        newData.logBookId = data.logBookId
        newData.saveStatus = data.saveStatus
        
        // Overview 복사
        if let overview = data.overview {
            newData.overview = DiveOverview(
                title: overview.title,
                point: overview.point,
                purpose: overview.purpose,
                method: overview.method
            )
        }
        
        // Participants 복사
        if let participants = data.participants {
            newData.participants = DiveParticipants(
                leader: participants.leader,
                buddy: participants.buddy,
                companion: participants.companion
            )
        }
        
        // Equipment 복사
        if let equipment = data.equipment {
            newData.equipment = DiveEquipment(
                suitType: equipment.suitType,
                Equipment: equipment.Equipment,
                weight: equipment.weight,
                pweight: equipment.pweight
            )
        }
        
        // Environment 복사
        if let environment = data.environment {
            newData.environment = DiveEnvironment(
                weather: environment.weather,
                wind: environment.wind,
                current: environment.current,
                wave: environment.wave,
                airTemp: environment.airTemp,
                feelsLike: environment.feelsLike,
                waterTemp: environment.waterTemp,
                visibility: environment.visibility
            )
        }
        
        // Profile 복사
        if let profile = data.profile {
            newData.profile = DiveProfile(
                diveTime: profile.diveTime,
                maxDepth: profile.maxDepth,
                avgDepth: profile.avgDepth,
                decoStop: profile.decoStop,
                startPressure: profile.startPressure,
                endPressure: profile.endPressure
            )
        }
        
        return newData
    }
    
    // 에러 메시지 클리어
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - 비교 메서드들 (기존 코드 유지)
    
    private func areOverviewEqual(_ overview1: DiveOverview?, _ overview2: DiveOverview?) -> Bool {
        if overview1 == nil && overview2 == nil { return true }
        guard let o1 = overview1, let o2 = overview2 else { return false }
        
        return o1.title == o2.title &&
               o1.point == o2.point &&
               o1.purpose == o2.purpose &&
               o1.method == o2.method
    }
    
    private func areParticipantsEqual(_ participants1: DiveParticipants?, _ participants2: DiveParticipants?) -> Bool {
        if participants1 == nil && participants2 == nil { return true }
        guard let p1 = participants1, let p2 = participants2 else { return false }
        
        return p1.leader == p2.leader &&
               p1.buddy == p2.buddy &&
               p1.companion == p2.companion
    }
    
    private func areEquipmentEqual(_ equipment1: DiveEquipment?, _ equipment2: DiveEquipment?) -> Bool {
        if equipment1 == nil && equipment2 == nil { return true }
        guard let e1 = equipment1, let e2 = equipment2 else { return false }
        
        return e1.suitType == e2.suitType &&
               e1.Equipment == e2.Equipment &&
               e1.weight == e2.weight &&
               e1.pweight == e2.pweight
    }
    
    private func areEnvironmentEqual(_ environment1: DiveEnvironment?, _ environment2: DiveEnvironment?) -> Bool {
        if environment1 == nil && environment2 == nil { return true }
        guard let e1 = environment1, let e2 = environment2 else { return false }
        
        return e1.weather == e2.weather &&
               e1.wind == e2.wind &&
               e1.current == e2.current &&
               e1.wave == e2.wave &&
               e1.airTemp == e2.airTemp &&
               e1.feelsLike == e2.feelsLike &&
               e1.waterTemp == e2.waterTemp &&
               e1.visibility == e2.visibility
    }
    
    private func areProfileEqual(_ profile1: DiveProfile?, _ profile2: DiveProfile?) -> Bool {
        if profile1 == nil && profile2 == nil { return true }
        guard let p1 = profile1, let p2 = profile2 else { return false }
        
        return p1.diveTime == p2.diveTime &&
               p1.maxDepth == p2.maxDepth &&
               p1.avgDepth == p2.avgDepth &&
               p1.decoStop == p2.decoStop &&
               p1.startPressure == p2.startPressure &&
               p1.endPressure == p2.endPressure
    }
}
