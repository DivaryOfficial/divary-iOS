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
    
    // ✅ 서버에서 받은 총 다이빙 횟수 추가
    var totalDiveCount: Int = 0
    
    // ✅ 단순화된 임시저장 구조
    var isTempSaved: Bool = false                    // 서버 저장 상태 표시용
    var frontendTempData: [DiveLogData] = []        // 프론트엔드 임시저장 데이터만 유지
    var hasFrontendTempSave: [Bool] = []            // 각 페이지별 프론트엔드 임시저장 여부
    var serverData: [DiveLogData] = []              // 서버에서 불러온 원본 데이터 (그냥 나가기용)
    
    // 저장 관련 상태
    var showSavePopup = false
    var showSavedMessage = false
    
    // ✅ 추가: 제목 관련 프론트엔드 임시저장
    var frontendTempTitle: String? = nil
    var hasTitleChanges: Bool = false
    
    // API 연동 관련
    private let dataManager = LogBookDataManager.shared
    private let service = LogBookService.shared
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    
    // ✅ 기존 logCount는 제거하고 totalDiveCount 사용
    
    // ✅ 프론트엔드 임시저장이 있는지 확인하는 계산 프로퍼티 추가
    var hasFrontendChanges: Bool {
        return hasFrontendTempSave.contains(true) || hasTitleChanges
    }
    
    // ✅ 수정: displayTitle 계산 프로퍼티 (38줄 부근)
    var displayTitle: String {
        return frontendTempTitle ?? logBaseTitle
    }
    
    // 기존 init (기본값용)
     init() {
         self.logBaseId = ""
         self.logBaseInfoId = 0
         self.diveLogData = [] // 빈 배열로 시작
         self.logBaseTitle = "다이빙 로그북"
         self.totalDiveCount = 0 // ✅ 추가
         self.frontendTempData = []
         self.hasFrontendTempSave = []
         self.serverData = []
     }
     
     // logBaseId를 받는 init
     init(logBaseId: String) {
         self.logBaseId = logBaseId
         self.logBaseInfoId = Int(logBaseId) ?? 0
         self.diveLogData = [] // 빈 배열로 시작
         self.totalDiveCount = 0 // ✅ 추가
         self.frontendTempData = []
         self.hasFrontendTempSave = []
         self.serverData = []
         
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
        totalDiveCount = logBase.accumulation // ✅ 서버에서 받은 accumulation 값 저장
        
        // 로그북 데이터 업데이트 (동적 개수)
        diveLogData = []
        
        for logBook in logBase.logBooks {
            let logData = logBook.diveData
            logData.logBookId = logBook.logBookId
            logData.saveStatus = logBook.saveStatus
            diveLogData.append(logData)
            
            // 서버 저장 상태 확인 (TEMP든 COMPLETE든 서버에 저장된 상태)
            if logBook.saveStatus == .temp {
                isTempSaved = true
            }
        }
        
        // ✅ 서버에서 불러온 원본 데이터 백업 (그냥 나가기용)
        serverData = diveLogData.map { copyDiveLogData($0) }
        
        // ✅ 프론트엔드 임시저장 배열 초기화
        frontendTempData = diveLogData.map { copyDiveLogData($0) }
        hasFrontendTempSave = Array(repeating: false, count: diveLogData.count)
        
        print("✅ LogBase 업데이트 완료 - 로그북 개수: \(diveLogData.count), 총 다이빙 횟수: \(totalDiveCount)")
    }
    

    // MARK: - 날짜 수정 관련 메서드

    // 로그베이스 날짜 업데이트 (서버에)
    func updateLogBaseDateToServer(newDate: Date, completion: @escaping (Bool) -> Void) {
        let dateString = DateFormatter.apiDateFormatter.string(from: newDate)
        
        isLoading = true
        errorMessage = nil
        
        service.updateLogBaseDate(logBaseInfoId: logBaseInfoId, date: dateString) { result in
            self.isLoading = false
            
            switch result {
            case .success:
                self.selectedDate = newDate
                completion(true)
                print("✅ 날짜 서버 저장 성공: \(dateString)")
                
            case .failure(let error):
                self.errorMessage = "날짜 수정 중 오류가 발생했습니다: \(error.localizedDescription)"
                completion(false)
                print("❌ 날짜 서버 저장 실패: \(error)")
            }
        }
    }
    
    // MARK: - ✅ 프론트엔드 임시저장 관련 메서드
    
    // 프론트엔드 임시저장
    func saveFrontendTemp(for index: Int) {
        guard index < diveLogData.count && index < frontendTempData.count else { return }
        
        frontendTempData[index] = copyDiveLogData(diveLogData[index])
        hasFrontendTempSave[index] = true
        
        print("✅ 프론트엔드 임시저장 완료: 페이지 \(index)")
    }
    
    // ✅ 변경사항 감지 로직 (단순화)
    func hasChangesFromLastSave(for index: Int) -> Bool {
        guard index < diveLogData.count else { return false }
        
        let current = diveLogData[index]
        
        // 1. 프론트엔드 임시저장이 있으면 그것과 비교
        if index < hasFrontendTempSave.count && hasFrontendTempSave[index] {
            let frontendTemp = frontendTempData[index]
            return !areDataEqual(current, frontendTemp)
        }
        
        // 2. 프론트엔드 임시저장이 없으면 서버 원본 데이터와 비교
        if index < serverData.count {
            let serverOriginal = serverData[index]
            return !areDataEqual(current, serverOriginal)
        }
        
        // 3. 둘 다 없으면 빈 데이터와 비교
        let emptyData = DiveLogData()
        return !areDataEqual(current, emptyData)
    }
    
    // ✅ 수정: discardCurrentInput 메서드 (290줄 부근 - 제목 복원 로직 추가)
    func discardCurrentInput(for index: Int) {
        guard index < diveLogData.count else { return }
        
        // 제목 변경사항 취소
        frontendTempTitle = nil
        hasTitleChanges = false
        
        // 기존 로직 (로그북 데이터 복원)
        if index < hasFrontendTempSave.count && hasFrontendTempSave[index] {
            diveLogData[index] = copyDiveLogData(frontendTempData[index])
            print("✅ 프론트엔드 임시저장으로 복원: 페이지 \(index)")
            return
        }
        
        print("🔄 서버 최신 데이터로 복원 시작")
        loadLogBaseDetail()
    }
    
    // MARK: - ✅ 서버 저장 관련 메서드 (메인뷰에서만 사용)
    
    // 개별 로그북 저장 (서버에)
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
                
                // 서버 원본 데이터 업데이트
                if index < self.serverData.count {
                    self.serverData[index] = self.copyDiveLogData(self.diveLogData[index])
                }
                
                
                // 서버 저장 상태 업데이트
                if saveStatus == .temp {
                    self.isTempSaved = true
                } else {
                    // ✅ 완전저장: 모든 로그북이 완전저장되었는지 확인
                    self.updateTempSavedStatus()
                }
                
                // ✅ 프론트엔드 임시저장은 서버 저장과 별개로 유지 (제거하지 않음)
                
                completion(true)
                
                // ✅ 추가: 메인 화면 데이터 새로고침
                let currentYear = Calendar.current.component(.year, from: self.selectedDate)
                LogBookDataManager.shared.refreshCache(for: currentYear)
                print("✅ 로그북 서버 저장 성공: logBookId=\(logBookId), saveStatus=\(saveStatus.rawValue)")
                
            case .failure(let error):
                self.errorMessage = "저장 중 오류가 발생했습니다: \(error.localizedDescription)"
                completion(false)
                print("❌ 로그북 서버 저장 실패: \(error)")
            }
        }
    }
    
    // MARK: - 저장 관련 메서드 (메인뷰 저장 버튼용)
    
    // 저장 버튼 처리
    func handleSaveButtonTap(currentPageIndex: Int = -1) {
        if currentPageIndex >= 0 {
            // ✅ 현재 페이지만 체크
            if areAllSectionsComplete(for: currentPageIndex) {
                handleCompleteSave(currentPageIndex: currentPageIndex)
            } else {
                showSavePopup = true
            }
        } else {
            // 기존 로직 (모든 페이지) - 하위 호환성
            if areAllSectionsCompleteForAllPages() {
                handleCompleteSave()
            } else {
                showSavePopup = true
            }
        }
    }
    
    // ✅ 수정: handleCompleteSave 메서드
    func handleCompleteSave(currentPageIndex: Int = -1) {
        var completedCount = 0
        let needsTitleSave = hasTitleChanges
        
        if currentPageIndex >= 0 {
            // ✅ 현재 페이지만 저장
            let needsLogBookSave = currentPageIndex < diveLogData.count && !diveLogData[currentPageIndex].isEmpty
            let totalOperations = (needsTitleSave ? 1 : 0) + (needsLogBookSave ? 1 : 0)
            
            guard totalOperations > 0 else {
                showSavedMessage = true
                showSavePopup = false
                return
            }
            
            // 제목 저장
            if needsTitleSave, let newTitle = frontendTempTitle {
                updateLogBaseTitleToServer(newTitle: newTitle) { success in
                    if success {
                        self.frontendTempTitle = nil
                        self.hasTitleChanges = false
                        completedCount += 1
                        if completedCount == totalOperations {
                            self.showSavedMessage = true
                            self.showSavePopup = false
                            // ✅ 현재 페이지의 프론트엔드 임시저장만 클리어
                            if currentPageIndex < self.hasFrontendTempSave.count {
                                self.hasFrontendTempSave[currentPageIndex] = false
                            }
                        }
                    }
                }
            }
            
            // ✅ 현재 페이지의 로그북만 저장
            if needsLogBookSave {
                saveLogBook(at: currentPageIndex, saveStatus: .complete) { success in
                    if success {
                        completedCount += 1
                        if completedCount == totalOperations {
                            self.showSavedMessage = true
                            self.showSavePopup = false
                            // ✅ 현재 페이지의 프론트엔드 임시저장만 클리어
                            if currentPageIndex < self.hasFrontendTempSave.count {
                                self.hasFrontendTempSave[currentPageIndex] = false
                            }
                        }
                    }
                }
            }
        } else {
            // 기존 로직 (모든 페이지) - 하위 호환성
            let totalSaves = diveLogData.filter { !$0.isEmpty }.count
            let totalOperations = totalSaves + (needsTitleSave ? 1 : 0)
            
            guard totalOperations > 0 else {
                showSavedMessage = true
                return
            }
            
            // 제목 저장
            if needsTitleSave, let newTitle = frontendTempTitle {
                updateLogBaseTitleToServer(newTitle: newTitle) { success in
                    if success {
                        self.frontendTempTitle = nil
                        self.hasTitleChanges = false
                        completedCount += 1
                        if completedCount == totalOperations {
                            self.showSavedMessage = true
                            self.showSavePopup = false
                            self.hasFrontendTempSave = Array(repeating: false, count: self.diveLogData.count)
                        }
                    }
                }
            }
            
            // 로그북 데이터 저장 (기존 로직)
            for (index, data) in diveLogData.enumerated() {
                if !data.isEmpty {
                    saveLogBook(at: index, saveStatus: .complete) { success in
                        if success {
                            completedCount += 1
                            if completedCount == totalOperations {
                                self.showSavedMessage = true
                                self.showSavePopup = false
                                self.hasFrontendTempSave = Array(repeating: false, count: self.diveLogData.count)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // ✅ 수정: handleTempSaveFromSavePopup 메서드
    func handleTempSaveFromSavePopup(currentPageIndex: Int = -1) {
        var completedCount = 0
        let needsTitleSave = hasTitleChanges
        
        if currentPageIndex >= 0 {
            // ✅ 현재 페이지만 임시저장
            let needsLogBookSave = currentPageIndex < diveLogData.count && !diveLogData[currentPageIndex].isEmpty
            let totalOperations = (needsTitleSave ? 1 : 0) + (needsLogBookSave ? 1 : 0)
            
            guard totalOperations > 0 else {
                showSavePopup = false
                return
            }
            
            // 제목 저장
            if needsTitleSave, let newTitle = frontendTempTitle {
                updateLogBaseTitleToServer(newTitle: newTitle) { success in
                    if success {
                        self.frontendTempTitle = nil
                        self.hasTitleChanges = false
                        completedCount += 1
                        if completedCount == totalOperations {
                            self.showSavePopup = false
                            // ✅ 현재 페이지의 프론트엔드 임시저장만 클리어
                            if currentPageIndex < self.hasFrontendTempSave.count {
                                self.hasFrontendTempSave[currentPageIndex] = false
                            }
                        }
                    }
                }
            }
            
            // ✅ 현재 페이지의 로그북만 임시저장
            if needsLogBookSave {
                saveLogBook(at: currentPageIndex, saveStatus: .temp) { success in
                    if success {
                        completedCount += 1
                        if completedCount == totalOperations {
                            self.showSavePopup = false
                            // ✅ 현재 페이지의 프론트엔드 임시저장만 클리어
                            if currentPageIndex < self.hasFrontendTempSave.count {
                                self.hasFrontendTempSave[currentPageIndex] = false
                            }
                        }
                    }
                }
            }
        } else {
            // 기존 로직 (모든 페이지) - 하위 호환성
            let totalSaves = diveLogData.filter { !$0.isEmpty }.count
            let totalOperations = totalSaves + (needsTitleSave ? 1 : 0)
            
            guard totalOperations > 0 else {
                showSavePopup = false
                return
            }
            
            // 제목 저장
            if needsTitleSave, let newTitle = frontendTempTitle {
                updateLogBaseTitleToServer(newTitle: newTitle) { success in
                    if success {
                        self.frontendTempTitle = nil
                        self.hasTitleChanges = false
                        completedCount += 1
                        if completedCount == totalOperations {
                            self.showSavePopup = false
                            self.hasFrontendTempSave = Array(repeating: false, count: self.diveLogData.count)
                        }
                    }
                }
            }
            
            // 로그북 데이터 저장 (기존 로직)
            for (index, data) in diveLogData.enumerated() {
                if !data.isEmpty {
                    saveLogBook(at: index, saveStatus: .temp) { success in
                        if success {
                            completedCount += 1
                            if completedCount == totalOperations {
                                self.showSavePopup = false
                                self.hasFrontendTempSave = Array(repeating: false, count: self.diveLogData.count)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 제목 수정 관련 업데이트
    
    // ✅ 추가: 프론트엔드 제목 업데이트 메서드 (updateFromLogBase 메서드 다음에 추가)
    func updateFrontendTitle(newTitle: String) {
        let trimmedTitle = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedTitle != logBaseTitle {
            frontendTempTitle = trimmedTitle
            hasTitleChanges = true
        } else {
            frontendTempTitle = nil
            hasTitleChanges = false
        }
        print("✅ 프론트엔드 제목 임시저장: \(trimmedTitle)")
    }
    
    // ✅ 추가: 서버 제목 업데이트 메서드 (기존 updateLogBaseTitle 메서드 대체/추가)
    private func updateLogBaseTitleToServer(newTitle: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        service.updateLogBaseTitle(logBaseInfoId: logBaseInfoId, name: newTitle) { result in
            self.isLoading = false
            
            switch result {
            case .success:
                self.logBaseTitle = newTitle
                completion(true)
                print("✅ 제목 서버 저장 성공: \(newTitle)")
                
            case .failure(let error):
                self.errorMessage = "제목 수정 중 오류가 발생했습니다: \(error.localizedDescription)"
                completion(false)
                print("❌ 제목 서버 저장 실패: \(error)")
            }
        }
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
    
    // ✅ 전체 임시저장 상태 업데이트 (새로 추가)
    private func updateTempSavedStatus() {
        // 모든 로그북이 완전저장(COMPLETE) 상태인지 확인
        let hasAnyTempSaved = diveLogData.contains { data in
            data.saveStatus == .temp && !data.isEmpty
        }
        
        isTempSaved = hasAnyTempSaved
        print("✅ 임시저장 상태 업데이트: \(isTempSaved)")
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
                decoDepth: profile.decoDepth,
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
    
    private func areDataEqual(_ data1: DiveLogData, _ data2: DiveLogData) -> Bool {
        return areOverviewEqual(data1.overview, data2.overview) &&
               areParticipantsEqual(data1.participants, data2.participants) &&
               areEquipmentEqual(data1.equipment, data2.equipment) &&
               areEnvironmentEqual(data1.environment, data2.environment) &&
               areProfileEqual(data1.profile, data2.profile)
    }
    
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
               p1.decoDepth == p2.decoDepth &&
               p1.decoStop == p2.decoStop &&
               p1.startPressure == p2.startPressure &&
               p1.endPressure == p2.endPressure
    }
}
