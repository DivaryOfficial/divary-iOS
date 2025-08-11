//
//  LogBookMainViewModel.swift
//  Divary
//
//  Created by 바견규 on 7/17/25.
//

import SwiftUI

@Observable
class LogBookMainViewModel {
    var diveLogData: [DiveLogData]
    var selectedDate = Date()
    var logBaseId: String
    var logBaseTitle: String = "" // 추가: 로그베이스 제목
    var isTempSaved: Bool = false // 임시저장 상태
    var tempSavedData: [DiveLogData] = [] // 임시저장된 데이터 백업
    
    // 저장 관련 상태
    var showSavePopup = false
    var showSavedMessage = false
    
    private let dataManager = MockDataManager.shared
    
    var logCount: Int {
        3 - diveLogData.filter { $0.isEmpty }.count
    }
    
    // 기존 init (기본값용)
    init() {
        self.logBaseId = ""
        self.diveLogData = LogBookPageMock
        self.logBaseTitle = "다이빙 로그북"
        self.tempSavedData = Array(repeating: DiveLogData(), count: 3)
    }
    
    // logBaseId를 받는 init
    init(logBaseId: String) {
        self.logBaseId = logBaseId
        // MockDataManager에서 해당 logBaseId의 로그북들과 제목 가져오기
        if let logBase = dataManager.logBookBases.first(where: { $0.id == logBaseId }) {
            self.diveLogData = logBase.logBooks
            self.selectedDate = logBase.date
            self.logBaseTitle = logBase.title
        } else {
            self.diveLogData = [DiveLogData(), DiveLogData(), DiveLogData()]
            self.logBaseTitle = "새 다이빙 로그"
        }
        self.tempSavedData = Array(repeating: DiveLogData(), count: 3)
    }
    
    // MARK: - 저장 관련 메서드
    
    // 저장 버튼 처리
    func handleSaveButtonTap() {
        // 1. 모든 섹션이 완성되어 있는지 확인
        if areAllSectionsCompleteForAllPages() {
            // 모든 섹션이 완성됨 -> 바로 저장
            handleCompleteSave()
        } else {
            // 일부 섹션이 미완성 -> SavePop 표시
            showSavePopup = true
        }
    }
    
    // 모든 페이지의 모든 섹션이 완성되었는지 확인
    private func areAllSectionsCompleteForAllPages() -> Bool {
        for (index, _) in diveLogData.enumerated() {
            if !areAllSectionsComplete(for: index) {
                return false
            }
        }
        return true
    }
    
    // 작성 완료하기 (진짜 저장)
    func handleCompleteSave() {
        // 진짜 저장 로직 (API 호출 등)
        // TODO: API 연동시 구현
        
        // 임시저장 상태 해제
        isTempSaved = false
        
        // 저장 완료 메시지 표시 (ComPop - 자동으로 사라지지 않음)
        withAnimation {
            showSavedMessage = true
            showSavePopup = false
        }
    }
    
    // 임시 저장하기 (SavePop에서 호출)
    func handleTempSaveFromSavePopup() {
        tempSave()
        
        // SavePop 닫기
        withAnimation {
            showSavePopup = false
        }
    }
    
    // MARK: - 기존 메서드들
    
    // 모든 섹션이 완성되었는지 체크 (간소화된 버전)
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
    
    // DiveOverview 비교
    private func areOverviewEqual(_ overview1: DiveOverview?, _ overview2: DiveOverview?) -> Bool {
        if overview1 == nil && overview2 == nil { return true }
        guard let o1 = overview1, let o2 = overview2 else { return false }
        
        return o1.title == o2.title &&
               o1.point == o2.point &&
               o1.purpose == o2.purpose &&
               o1.method == o2.method
    }
    
    // DiveParticipants 비교
    private func areParticipantsEqual(_ participants1: DiveParticipants?, _ participants2: DiveParticipants?) -> Bool {
        if participants1 == nil && participants2 == nil { return true }
        guard let p1 = participants1, let p2 = participants2 else { return false }
        
        return p1.leader == p2.leader &&
               p1.buddy == p2.buddy &&
               p1.companion == p2.companion
    }
    
    // DiveEquipment 비교
    private func areEquipmentEqual(_ equipment1: DiveEquipment?, _ equipment2: DiveEquipment?) -> Bool {
        if equipment1 == nil && equipment2 == nil { return true }
        guard let e1 = equipment1, let e2 = equipment2 else { return false }
        
        return e1.suitType == e2.suitType &&
               e1.Equipment == e2.Equipment &&
               e1.weight == e2.weight &&
               e1.pweight == e2.pweight
    }
    
    // DiveEnvironment 비교
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
    
    // DiveProfile 비교
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
    
    // 현재 페이지의 모든 필드 초기화
    func clearAllFields(for index: Int) {
        guard index < diveLogData.count else { return }
        
        diveLogData[index] = DiveLogData()
        isTempSaved = false
        
        // 임시저장 데이터도 초기화
        if index < tempSavedData.count {
            tempSavedData[index] = DiveLogData()
        }
    }
    
    // 임시저장
    func tempSave() {
        // 현재 데이터를 tempSavedData에 백업
        tempSavedData = diveLogData.map { data in
            let newData = DiveLogData()
            
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
        
        isTempSaved = true
    }
    
    // 임시저장된 데이터로 되돌리기
    func restoreFromTempSave(for index: Int) {
        guard index < diveLogData.count && index < tempSavedData.count else { return }
        
        let tempData = tempSavedData[index]
        let newData = DiveLogData()
        
        // Overview 복사
        if let overview = tempData.overview {
            newData.overview = DiveOverview(
                title: overview.title,
                point: overview.point,
                purpose: overview.purpose,
                method: overview.method
            )
        }
        
        // Participants 복사
        if let participants = tempData.participants {
            newData.participants = DiveParticipants(
                leader: participants.leader,
                buddy: participants.buddy,
                companion: participants.companion
            )
        }
        
        // Equipment 복사
        if let equipment = tempData.equipment {
            newData.equipment = DiveEquipment(
                suitType: equipment.suitType,
                Equipment: equipment.Equipment,
                weight: equipment.weight,
                pweight: equipment.pweight
            )
        }
        
        // Environment 복사
        if let environment = tempData.environment {
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
        if let profile = tempData.profile {
            newData.profile = DiveProfile(
                diveTime: profile.diveTime,
                maxDepth: profile.maxDepth,
                avgDepth: profile.avgDepth,
                decoStop: profile.decoStop,
                startPressure: profile.startPressure,
                endPressure: profile.endPressure
            )
        }
        
        diveLogData[index] = newData
    }
}
