//
//  LogBookMainViewModel.swift - 기존 코드를 API 연결로 수정
//

import SwiftUI
import Foundation

@Observable
class LogBookMainViewModel {
    var diveLogData: [DiveLogData]
    var selectedDate = Date()
    var logBaseId: String
    var logBaseTitle: String = ""
    var isTempSaved: Bool = false
    var tempSavedData: [DiveLogData] = []
    
    // 저장 관련 상태
    var showSavePopup = false
    var showSavedMessage = false
    
    // API 관련 추가
    var isLoading: Bool = false
    private let service = LogBookService()
    
    var logCount: Int {
        3 - diveLogData.filter { $0.isEmpty }.count
    }
    
    // 기존 init (기본값용)
    init() {
        self.logBaseId = ""
        self.diveLogData = [DiveLogData(), DiveLogData(), DiveLogData()] // Mock 데이터 대신 빈 데이터
        self.logBaseTitle = "다이빙 로그북"
        self.tempSavedData = Array(repeating: DiveLogData(), count: 3)
    }
    
    // logBaseId를 받는 init - API 연결로 수정
    init(logBaseId: String) {
        self.logBaseId = logBaseId
        self.diveLogData = [DiveLogData(), DiveLogData(), DiveLogData()]
        self.logBaseTitle = "새 다이빙 로그"
        self.tempSavedData = Array(repeating: DiveLogData(), count: 3)
        
        // API에서 데이터를 로드하는 것은 별도의 함수에서 처리
    }
    
    // MARK: - API 관련 메서드 추가
    
    // 로그 상세 데이터 로드
    func loadLogDetail() async {
        guard let id = Int(logBaseId) else { return }
        
        await MainActor.run {
            isLoading = true
        }
        
        do {
            let response = try await withCheckedThrowingContinuation { continuation in
                service.getLogDetail(id: id) { result in
                    continuation.resume(with: result)
                }
            }
            
            await MainActor.run {
                self.parseLogDetailResponse(response)
                self.isLoading = false
            }
        } catch {
            print("❌ 로그 상세 로드 실패: \(error)")
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    // 빈 로그 페이지 생성
    func createEmptyLogPage() async {
        guard let id = Int(logBaseId) else { return }
        
        do {
            let response = try await withCheckedThrowingContinuation { continuation in
                service.createEmptyLog(id: id) { result in
                    continuation.resume(with: result)
                }
            }
            
            await MainActor.run {
                self.parseLogDetailResponse(response)
            }
        } catch {
            print("❌ 빈 로그 페이지 생성 실패: \(error)")
        }
    }
    
    // 로그 데이터 저장 (API)
    func saveLogDataToAPI() async -> Bool {
        guard let id = Int(logBaseId),
              let updateData = createUpdateRequestDTO() else { return false }
        
        do {
            let response = try await withCheckedThrowingContinuation { continuation in
                service.updateLog(id: id, logData: updateData) { result in
                    continuation.resume(with: result)
                }
            }
            
            await MainActor.run {
                self.parseLogDetailResponse(response)
                self.isTempSaved = false
            }
            return true
        } catch {
            print("❌ 로그 저장 실패: \(error)")
            return false
        }
    }
    
    // MARK: - 기존 저장 관련 메서드 (API 연결 추가)
    
    // 저장 버튼 처리
    func handleSaveButtonTap() {
        if areAllSectionsCompleteForAllPages() {
            handleCompleteSave()
        } else {
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
    
    // 작성 완료하기 (진짜 저장) - API 호출 추가
    func handleCompleteSave() {
        Task {
            let success = await saveLogDataToAPI()
            await MainActor.run {
                if success {
                    self.isTempSaved = false
                    withAnimation {
                        self.showSavedMessage = true
                        self.showSavePopup = false
                    }
                } else {
                    // 실패 처리 (토스트 메시지 등)
                    print("저장에 실패했습니다.")
                }
            }
        }
    }
    
    // 임시 저장하기 (SavePop에서 호출) - API 호출 추가
    func handleTempSaveFromSavePopup() {
        Task {
            // 임시 상태로 API에 저장
            await saveTempDataToAPI()
            
            await MainActor.run {
                self.tempSave() // 로컬에도 임시저장
                withAnimation {
                    self.showSavePopup = false
                }
            }
        }
    }
    
    // 임시 데이터를 API에 저장
    private func saveTempDataToAPI() async {
        guard let id = Int(logBaseId),
              let updateData = createUpdateRequestDTO(saveStatus: "TEMP") else { return }
        
        do {
            let _ = try await withCheckedThrowingContinuation { continuation in
                service.updateLog(id: id, logData: updateData) { result in
                    continuation.resume(with: result)
                }
            }
            print("임시저장 완료")
        } catch {
            print("❌ 임시저장 실패: \(error)")
        }
    }
    
    // MARK: - 기존 메서드들 유지
    
    func areAllSectionsComplete(for index: Int) -> Bool {
        guard index < diveLogData.count else { return false }
        
        let data = diveLogData[index]
        let sections: [InputSectionType] = [.overview, .participants, .equipment, .environment, .profile]
        
        return sections.allSatisfy { section in
            getSectionStatus(for: data, section: section) == .complete
        }
    }
    
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
    
    func hasChangesFromTempSave(for index: Int) -> Bool {
        guard index < diveLogData.count && index < tempSavedData.count else { return false }
        
        let current = diveLogData[index]
        let tempSaved = tempSavedData[index]
        
        return !areDataEqual(current, tempSaved)
    }
    
    // 기존의 모든 비교 및 임시저장 메서드들 유지...
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
               p1.decoStop == p2.decoStop &&
               p1.startPressure == p2.startPressure &&
               p1.endPressure == p2.endPressure
    }
    
    func clearAllFields(for index: Int) {
        guard index < diveLogData.count else { return }
        
        diveLogData[index] = DiveLogData()
        isTempSaved = false
        
        if index < tempSavedData.count {
            tempSavedData[index] = DiveLogData()
        }
    }
    
    func tempSave() {
        tempSavedData = diveLogData.map { data in
            let newData = DiveLogData()
            
            if let overview = data.overview {
                newData.overview = DiveOverview(
                    title: overview.title,
                    point: overview.point,
                    purpose: overview.purpose,
                    method: overview.method
                )
            }
            
            if let participants = data.participants {
                newData.participants = DiveParticipants(
                    leader: participants.leader,
                    buddy: participants.buddy,
                    companion: participants.companion
                )
            }
            
            if let equipment = data.equipment {
                newData.equipment = DiveEquipment(
                    suitType: equipment.suitType,
                    Equipment: equipment.Equipment,
                    weight: equipment.weight,
                    pweight: equipment.pweight
                )
            }
            
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
    
    func restoreFromTempSave(for index: Int) {
        guard index < diveLogData.count && index < tempSavedData.count else { return }
        
        let tempData = tempSavedData[index]
        let newData = DiveLogData()
        
        if let overview = tempData.overview {
            newData.overview = DiveOverview(
                title: overview.title,
                point: overview.point,
                purpose: overview.purpose,
                method: overview.method
            )
        }
        
        if let participants = tempData.participants {
            newData.participants = DiveParticipants(
                leader: participants.leader,
                buddy: participants.buddy,
                companion: participants.companion
            )
        }
        
        if let equipment = tempData.equipment {
            newData.equipment = DiveEquipment(
                suitType: equipment.suitType,
                Equipment: equipment.Equipment,
                weight: equipment.weight,
                pweight: equipment.pweight
            )
        }
        
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
    
    // MARK: - API 변환 Helper Methods
    
    private func parseLogDetailResponse(_ response: LogDetailResponseDTO) {
        let logData = DiveLogData()
        
        // 데이터가 있는 경우에만 섹션 생성
        if response.place != nil || response.divePoint != nil || response.diveMethod != nil || response.divePurpose != nil {
            logData.overview = DiveOverview(
                title: response.place,
                point: response.divePoint,
                purpose: response.divePurpose,
                method: response.diveMethod
            )
        }
        
        if let companions = response.companions, !companions.isEmpty {
            let leader = companions.first { $0.type == "LEADER" }?.name
            let buddy = companions.first { $0.type == "BUDDY" }?.name
            let companionNames = companions.filter { $0.type == "COMPANION" }.map { $0.name }
            
            logData.participants = DiveParticipants(
                leader: leader,
                buddy: buddy,
                companion: companionNames.isEmpty ? nil : companionNames
            )
        }
        
        if response.suitType != nil || response.equipment != nil || response.weight != nil || response.perceivedWeight != nil {
            logData.equipment = DiveEquipment(
                suitType: response.suitType,
                Equipment: response.equipment?.components(separatedBy: ","),
                weight: response.weight,
                pweight: response.perceivedWeight
            )
        }
        
        if response.weather != nil || response.wind != nil || response.tide != nil || response.wave != nil ||
           response.temperature != nil || response.perceivedTemp != nil || response.waterTemperature != nil || response.sight != nil {
            logData.environment = DiveEnvironment(
                weather: response.weather,
                wind: response.wind,
                current: response.tide,
                wave: response.wave,
                airTemp: response.temperature,
                feelsLike: response.perceivedTemp,
                waterTemp: response.waterTemperature,
                visibility: response.sight
            )
        }
        
        if response.diveTime != nil || response.maxDepth != nil || response.avgDepth != nil ||
           response.decompressTime != nil || response.startPressure != nil || response.finishPressure != nil {
            logData.profile = DiveProfile(
                diveTime: response.diveTime,
                maxDepth: response.maxDepth,
                avgDepth: response.avgDepth,
                decoStop: response.decompressTime,
                startPressure: response.startPressure,
                endPressure: response.finishPressure
            )
        }
        
        // 저장 상태 설정
        isTempSaved = response.saveStatus == "TEMP"
        
        // 로그 데이터 업데이트 (기존 3개 배열 구조 유지)
        if diveLogData.isEmpty {
            diveLogData = [logData, DiveLogData(), DiveLogData()]
        } else {
            diveLogData[0] = logData
        }
    }
    
    private func createUpdateRequestDTO(saveStatus: String? = nil) -> LogUpdateRequestDTO? {
        guard !diveLogData.isEmpty else { return nil }
        
        let logData = diveLogData[0] // 첫 번째 로그 데이터 사용
        
        // Companions 변환
        var companions: [CompanionDTO] = []
        if let participants = logData.participants {
            if let leader = participants.leader {
                companions.append(CompanionDTO(name: leader, type: "LEADER"))
            }
            if let buddy = participants.buddy {
                companions.append(CompanionDTO(name: buddy, type: "BUDDY"))
            }
            if let companionList = participants.companion {
                companions.append(contentsOf: companionList.map { CompanionDTO(name: $0, type: "COMPANION") })
            }
        }
        
        return LogUpdateRequestDTO(
            date: formatDate(selectedDate), // selectedDate 사용
            saveStatus: saveStatus ?? (isTempSaved ? "TEMP" : "COMPLETE"),
            place: logData.overview?.title,
            divePoint: logData.overview?.point,
            diveMethod: logData.overview?.method,
            divePurpose: logData.overview?.purpose,
            companions: companions.isEmpty ? nil : companions,
            suitType: logData.equipment?.suitType,
            equipment: logData.equipment?.Equipment?.joined(separator: ","),
            weight: logData.equipment?.weight,
            perceivedWeight: logData.equipment?.pweight,
            weather: logData.environment?.weather,
            wind: logData.environment?.wind,
            tide: logData.environment?.current,
            wave: logData.environment?.wave,
            temperature: logData.environment?.airTemp,
            waterTemperature: logData.environment?.waterTemp,
            perceivedTemp: logData.environment?.feelsLike,
            sight: logData.environment?.visibility,
            diveTime: logData.profile?.diveTime,
            maxDepth: logData.profile?.maxDepth,
            avgDepth: logData.profile?.avgDepth,
            decompressDepth: nil, // API에 있지만 모델에 없음
            decompressTime: logData.profile?.decoStop,
            startPressure: logData.profile?.startPressure,
            finishPressure: logData.profile?.endPressure,
            consumption: nil // 계산이 필요한 값
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
