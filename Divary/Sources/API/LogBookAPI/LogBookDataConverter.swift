
//  LogBookDataConverter.swift
//  Divary
//
//  Created by 개발자 on 8/11/25.
//

import Foundation

// MARK: - 날짜 변환 유틸리티
extension DateFormatter {
    static let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")
        // ✅ 타임존 명시적으로 설정
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter
    }()
    
    // ✅ 디버깅용 날짜 포맷터
    static let debugDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter
    }()
}

// MARK: - LogListResponseDTO → LogBookBase 변환
extension LogListResponseDTO {
    func toLogBookBase() -> LogBookBase {
        let date = DateFormatter.apiDateFormatter.date(from: self.date) ?? Date()
        let iconType = IconType(rawValue: self.iconType) ?? .clownfish
        let saveStatus = SaveStatus(rawValue: self.saveStatus) ?? .complete
        
        return LogBookBase(
            id: String(self.logBaseInfoId),
            logBaseInfoId: self.logBaseInfoId,
            date: date,
            title: self.name,
            iconType: iconType,
            accumulation: 0, // 리스트에서는 accumulation 정보가 없음
            logBooks: [] // 리스트에서는 상세 로그북 정보가 없음
        )
    }
}

// MARK: - LogBaseDetailDTO 배열 → LogBookBase 변환
extension Array where Element == LogBaseDetailDTO {
    func toLogBookBase(logBaseInfoId: Int) -> LogBookBase? {
        
        guard let firstItem = self.first else { return nil }
        
        let date = DateFormatter.apiDateFormatter.date(from: firstItem.date) ?? Date()
        let iconType = IconType(rawValue: firstItem.icon) ?? .clownfish
        
        let logBooks = self.map { dto in
            LogBook(
                id: String(dto.logBookId),
                logBookId: dto.logBookId,
                saveStatus: SaveStatus(rawValue: dto.saveStatus) ?? .complete,
                diveData: dto.toDiveLogData()
            )
        }
        
        return LogBookBase(
            id: String(logBaseInfoId),
            logBaseInfoId: logBaseInfoId,
            date: date,
            title: firstItem.name,
            iconType: iconType,
            accumulation: firstItem.accumulation,
            logBooks: logBooks
        )
    }
}

// MARK: - LogBaseDetailDTO → DiveLogData 변환
extension LogBaseDetailDTO {
    func toDiveLogData() -> DiveLogData {
        let diveData = DiveLogData()
        
        // Overview 섹션
        if hasOverviewData() {
            diveData.overview = DiveOverview(
                title: self.name,
                point: self.divePoint,
                purpose: self.divePurpose,
                method: self.diveMethod
            )
        }
        
        // Participants 섹션
        if hasParticipantsData() {
            let companionList = self.companions?.map { $0.companion } ?? []
            diveData.participants = DiveParticipants(
                leader: companionList.first,
                buddy: companionList.count > 1 ? companionList[1] : nil,
                companion: companionList.count > 2 ? Array(companionList.dropFirst(2)) : nil
            )
        }
        
        // Equipment 섹션
        if hasEquipmentData() {
            let equipmentList = self.equipment?.components(separatedBy: ",") ?? []
            diveData.equipment = DiveEquipment(
                suitType: self.suitType,
                Equipment: equipmentList,
                weight: self.weight,
                pweight: self.perceivedWeight
            )
        }
        
        // Environment 섹션
        if hasEnvironmentData() {
            diveData.environment = DiveEnvironment(
                weather: self.weather,
                wind: self.wind,
                current: self.tide,
                wave: self.wave,
                airTemp: self.temperature,
                feelsLike: self.perceivedTemp,
                waterTemp: self.waterTemperature,
                visibility: self.sight
            )
        }
        
        // Profile 섹션
        if hasProfileData() {
            diveData.profile = DiveProfile(
                diveTime: self.diveTime,
                maxDepth: self.maxDepth,
                avgDepth: self.avgDepth,
                decoStop: self.decompressTime,
                startPressure: self.startPressure,
                endPressure: self.finishPressure
            )
        }
        
        return diveData
    }
    
    // 섹션별 데이터 존재 여부 확인
    private func hasOverviewData() -> Bool {
        return divePoint != nil || divePurpose != nil || diveMethod != nil
    }
    
    private func hasParticipantsData() -> Bool {
        return companions?.isEmpty == false
    }
    
    private func hasEquipmentData() -> Bool {
        return suitType != nil || equipment != nil || weight != nil || perceivedWeight != nil
    }
    
    private func hasEnvironmentData() -> Bool {
        return weather != nil || wind != nil || tide != nil || wave != nil ||
               temperature != nil || waterTemperature != nil || perceivedTemp != nil || sight != nil
    }
    
    private func hasProfileData() -> Bool {
        return diveTime != nil || maxDepth != nil || avgDepth != nil ||
               decompressTime != nil || startPressure != nil || finishPressure != nil
    }
}

// MARK: - DiveLogData → LogUpdateRequestDTO 변환
extension DiveLogData {
    func toLogUpdateRequest(with date: Date, saveStatus: SaveStatus) -> LogUpdateRequestDTO {
        let dateString = DateFormatter.apiDateFormatter.string(from: date)
        
        return LogUpdateRequestDTO(
            date: dateString,
            saveStatus: saveStatus.rawValue,
            place: self.overview?.point, // place와 divePoint 매핑 확인 필요
            divePoint: self.overview?.point,
            diveMethod: self.overview?.method,
            divePurpose: self.overview?.purpose,
            companions: self.participants?.toCompanionDTOs(),
            suitType: self.equipment?.suitType,
            equipment: self.equipment?.Equipment?.joined(separator: ","),
            weight: self.equipment?.weight,
            perceivedWeight: self.equipment?.pweight,
            weather: self.environment?.weather,
            wind: self.environment?.wind,
            tide: self.environment?.current,
            wave: self.environment?.wave,
            temperature: self.environment?.airTemp,
            waterTemperature: self.environment?.waterTemp,
            perceivedTemp: self.environment?.feelsLike,
            sight: self.environment?.visibility,
            diveTime: self.profile?.diveTime,
            maxDepth: self.profile?.maxDepth,
            avgDepth: self.profile?.avgDepth,
            decompressDepth: nil, // API에는 있지만 UI에는 없는 필드
            decompressTime: self.profile?.decoStop,
            startPressure: self.profile?.startPressure,
            finishPressure: self.profile?.endPressure,
            consumption: nil // API에는 있지만 UI에는 없는 필드
        )
    }
}

// MARK: - DiveParticipants → CompanionDTO 배열 변환
extension DiveParticipants {
    func toCompanionDTOs() -> [CompanionDTO] {
        var companions: [CompanionDTO] = []
        
        if let leader = self.leader {
            companions.append(CompanionDTO(companion: leader, type: "LEADER"))
        }
        
        if let buddy = self.buddy {
            companions.append(CompanionDTO(companion: buddy, type: "BUDDY"))
        }
        
        if let companionList = self.companion {
            let companionDTOs = companionList.map { CompanionDTO(companion: $0, type: "COMPANION") }
            companions.append(contentsOf: companionDTOs)
        }
        
        return companions
    }
}

// MARK: - LogBaseDetailDTO 매핑 개선
//extension LogBaseDetailDTO {
//    var logBaseInfoId: Int? {
//        // GET /api/v1/logs/{logBaseInfoId} 호출에서 logBaseInfoId는 경로에서 추출 가능
//        // 실제로는 API 응답에서 제공되어야 하지만, 임시로 nil 처리
//        return nil
//    }
//}
