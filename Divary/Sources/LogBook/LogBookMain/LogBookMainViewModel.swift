//
//  LogBookMainViewModel.swift
//  Divary
//
//  Created by 바견규 on 7/17/25.
//

import SwiftUI

@Observable
class LogBookMainViewModel {
    // ✅ 배열에서 단일 객체로 변경
    var diveLogData: DiveLogData = DiveLogData()
    var selectedDate = Date()
    var logBaseId: String
    var logBaseInfoId: Int
    var logBaseTitle: String = ""
    
    // ✅ 서버에서 받은 총 다이빙 횟수
    var totalDiveCount: Int = 0
    
    // ✅ 단순화된 임시저장 구조 (인덱스 제거)
    var isTempSaved: Bool = false
    var frontendTempData: DiveLogData = DiveLogData()
    var hasFrontendTempSave: Bool = false
    var serverData: DiveLogData = DiveLogData()
    
    // 저장 관련 상태
    var showSavePopup = false
    var showSavedMessage = false
    
    // ✅ 제목 관련 프론트엔드 임시저장
    var frontendTempTitle: String? = nil
    var hasTitleChanges: Bool = false
    
    // API 연동 관련
    private let dataManager = LogBookDataManager.shared
    private let service = LogBookService.shared
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    
    // ✅ 프론트엔드 임시저장이 있는지 확인하는 계산 프로퍼티
    var hasFrontendChanges: Bool {
        return hasFrontendTempSave || hasTitleChanges
    }
    
    // ✅ displayTitle 계산 프로퍼티
    var displayTitle: String {
        return frontendTempTitle ?? logBaseTitle
    }
    
    // 기존 init (기본값용)
    init() {
        self.logBaseId = ""
        self.logBaseInfoId = 0
        self.diveLogData = DiveLogData()
        self.logBaseTitle = "다이빙 로그북"
        self.totalDiveCount = 0
        self.frontendTempData = DiveLogData()
        self.hasFrontendTempSave = false
        self.serverData = DiveLogData()
    }
    
    // logBaseId를 받는 init
    init(logBaseId: String) {
        self.logBaseId = logBaseId
        self.logBaseInfoId = Int(logBaseId) ?? 0
        self.diveLogData = DiveLogData()
        self.totalDiveCount = 0
        self.frontendTempData = DiveLogData()
        self.hasFrontendTempSave = false
        self.serverData = DiveLogData()
        
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
                DebugLogger.error("로그베이스 상세 조회 실패: \(error)")
            }
        }
    }
    
    // LogBase 데이터로 ViewModel 업데이트
    private func updateFromLogBase(_ logBase: LogBookBase) {
        selectedDate = logBase.date
        logBaseTitle = logBase.title
        totalDiveCount = logBase.accumulation
        
        // ✅ 첫 번째 로그북만 사용 (단일 로그북)
        if let firstLogBook = logBase.logBooks.first {
            let logData = firstLogBook.diveData
            logData.logBookId = firstLogBook.logBookId
            logData.saveStatus = firstLogBook.saveStatus
            diveLogData = logData
            
            // 서버 저장 상태 확인
            if firstLogBook.saveStatus == .temp {
                isTempSaved = true
            }
        } else {
            // 로그북이 없으면 빈 데이터
            diveLogData = DiveLogData()
        }
        
        // ✅ 서버에서 불러온 원본 데이터 백업
        serverData = copyDiveLogData(diveLogData)
        
        // ✅ 프론트엔드 임시저장 초기화
        frontendTempData = copyDiveLogData(diveLogData)
        hasFrontendTempSave = false
        
        DebugLogger.success("LogBase 업데이트 완료 - 총 다이빙 횟수: \(totalDiveCount)")
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
                DebugLogger.success("날짜 서버 저장 성공: \(dateString)")
                
            case .failure(let error):
                self.errorMessage = "날짜 수정 중 오류가 발생했습니다: \(error.localizedDescription)"
                completion(false)
                DebugLogger.error("날짜 서버 저장 실패: \(error)")
            }
        }
    }
    
    // MARK: - ✅ 프론트엔드 임시저장 관련 메서드 (인덱스 제거)
    
    // 프론트엔드 임시저장
    func saveFrontendTemp() {
        frontendTempData = copyDiveLogData(diveLogData)
        hasFrontendTempSave = true
        
        DebugLogger.success("프론트엔드 임시저장 완료")
    }
    
    // ✅ 변경사항 감지 로직 (단순화)
    func hasChangesFromLastSave() -> Bool {
        let current = diveLogData
        
        // 1. 프론트엔드 임시저장이 있으면 그것과 비교
        if hasFrontendTempSave {
            return !areDataEqual(current, frontendTempData)
        }
        
        // 2. 프론트엔드 임시저장이 없으면 서버 원본 데이터와 비교
        return !areDataEqual(current, serverData)
    }
    
    // ✅ 입력 취소 (제목 복원 포함)
    func discardCurrentInput() {
        // 제목 변경사항 취소
        frontendTempTitle = nil
        hasTitleChanges = false
        
        // 로그북 데이터 복원
        if hasFrontendTempSave {
            diveLogData = copyDiveLogData(frontendTempData)
            DebugLogger.success("프론트엔드 임시저장으로 복원")
            return
        }
        
        DebugLogger.log("서버 최신 데이터로 복원 시작")
        loadLogBaseDetail()
    }
    
    // MARK: - ✅ 서버 저장 관련 메서드
    
    // 로그북 저장 (서버에)
    func saveLogBook(saveStatus: SaveStatus, completion: @escaping (Bool) -> Void) {
        guard let logBookId = diveLogData.logBookId else {
            completion(false)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let logUpdateRequest = diveLogData.toLogUpdateRequest(
            with: selectedDate,
            saveStatus: saveStatus
        )
        
        service.updateLogBook(logBookId: logBookId, logData: logUpdateRequest) { result in
            self.isLoading = false
            
            switch result {
            case .success:
                // 저장 상태 업데이트
                self.diveLogData.saveStatus = saveStatus
                
                // 서버 원본 데이터 업데이트
                self.serverData = self.copyDiveLogData(self.diveLogData)
                
                // 서버 저장 상태 업데이트
                if saveStatus == .temp {
                    self.isTempSaved = true
                } else {
                    self.updateTempSavedStatus()
                }
                
                completion(true)
                
                // 메인 화면 데이터 새로고침
                let currentYear = Calendar.current.component(.year, from: self.selectedDate)
                LogBookDataManager.shared.refreshCache(for: currentYear)
                DebugLogger.success("로그북 서버 저장 성공: logBookId=\(logBookId), saveStatus=\(saveStatus.rawValue)")
                
            case .failure(let error):
                self.errorMessage = "저장 중 오류가 발생했습니다: \(error.localizedDescription)"
                completion(false)
                DebugLogger.error("로그북 서버 저장 실패: \(error)")
            }
        }
    }
    
    // MARK: - 저장 관련 메서드 (메인뷰 저장 버튼용)
    
    // 저장 버튼 처리
    func handleSaveButtonTap() {
        if areAllSectionsComplete() {
            handleCompleteSave()
        } else {
            showSavePopup = true
        }
    }
    
    // ✅ 완전저장
    func handleCompleteSave() {
        var completedCount = 0
        let needsTitleSave = hasTitleChanges
        let needsLogBookSave = !diveLogData.isEmpty
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
                        self.hasFrontendTempSave = false
                    }
                }
            }
        }
        
        // 로그북 데이터 저장
        if needsLogBookSave {
            saveLogBook(saveStatus: .complete) { success in
                if success {
                    completedCount += 1
                    if completedCount == totalOperations {
                        self.showSavedMessage = true
                        self.showSavePopup = false
                        self.hasFrontendTempSave = false
                    }
                }
            }
        }
    }
    
    // ✅ 임시저장
    func handleTempSaveFromSavePopup() {
        var completedCount = 0
        let needsTitleSave = hasTitleChanges
        let needsLogBookSave = !diveLogData.isEmpty
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
                        self.hasFrontendTempSave = false
                    }
                }
            }
        }
        
        // 로그북 데이터 저장
        if needsLogBookSave {
            saveLogBook(saveStatus: .temp) { success in
                if success {
                    completedCount += 1
                    if completedCount == totalOperations {
                        self.showSavePopup = false
                        self.hasFrontendTempSave = false
                    }
                }
            }
        }
    }
    
    // MARK: - 제목 수정 관련
    
    // 프론트엔드 제목 업데이트
    func updateFrontendTitle(newTitle: String) {
        let trimmedTitle = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedTitle != logBaseTitle {
            frontendTempTitle = trimmedTitle
            hasTitleChanges = true
        } else {
            frontendTempTitle = nil
            hasTitleChanges = false
        }
        DebugLogger.success("프론트엔드 제목 임시저장: \(trimmedTitle)")
    }
    
    // 서버 제목 업데이트
    private func updateLogBaseTitleToServer(newTitle: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        service.updateLogBaseTitle(logBaseInfoId: logBaseInfoId, name: newTitle) { result in
            self.isLoading = false
            
            switch result {
            case .success:
                self.logBaseTitle = newTitle
                completion(true)
                DebugLogger.success("제목 서버 저장 성공: \(newTitle)")
                
            case .failure(let error):
                self.errorMessage = "제목 수정 중 오류가 발생했습니다: \(error.localizedDescription)"
                completion(false)
                DebugLogger.error("제목 서버 저장 실패: \(error)")
            }
        }
    }
    
    // MARK: - 기존 메서드들
    
    // 모든 섹션이 완성되었는지 체크
    func areAllSectionsComplete() -> Bool {
        let data = diveLogData
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
    
    // 전체 임시저장 상태 업데이트
    private func updateTempSavedStatus() {
        let hasAnyTempSaved = diveLogData.saveStatus == .temp && !diveLogData.isEmpty
        isTempSaved = hasAnyTempSaved
        DebugLogger.success("임시저장 상태 업데이트: \(isTempSaved)")
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
    
    // MARK: - 비교 메서드들
    
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
