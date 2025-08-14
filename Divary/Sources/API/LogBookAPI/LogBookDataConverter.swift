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
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter
    }()

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
            logBooks: []
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
                saveStatus: SaveStatus(rawValue: dto.saveStatus ?? "TEMP") ?? .temp,
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

// MARK: - LogBaseDetailDTO → DiveLogData 변환 (백엔드 → UI)
extension LogBaseDetailDTO {
    func toDiveLogData() -> DiveLogData {
        let diveData = DiveLogData()

        // Overview - 백엔드 enum → UI 표시용 텍스트 변환
        if hasOverviewData() {
            diveData.overview = DiveOverview(
                title: self.name,
                point: self.divePoint,
                purpose: self.divePurpose != nil ? String.displayName(fromDivingPurposeEnum: self.divePurpose!) : nil,
                method: self.diveMethod != nil ? String.displayName(fromDivingMethodEnum: self.diveMethod!) : nil
            )
        }

        // ✅ Participants - 백엔드 타입 기반으로 UI 모델 구성
        if hasParticipantsData() {
            let participants = DiveParticipants()
            
            if let companionList = self.companions {
                for companion in companionList {
                    guard let name = companion.companion?.trimmingCharacters(in: .whitespacesAndNewlines),
                          !name.isEmpty else { continue }
                    
                    switch companion.type {
                    case "LEADER":
                        participants.leader = name
                    case "BUDDY":
                        participants.buddy = name
                    case "COMPANION":
                        if participants.companion == nil {
                            participants.companion = []
                        }
                        participants.companion?.append(name)
                    default:
                        print("⚠️ 알 수 없는 동행자 타입: \(companion.type)")
                        // 알 수 없는 타입도 동행자로 처리
                        if participants.companion == nil {
                            participants.companion = []
                        }
                        participants.companion?.append(name)
                    }
                }
            }
            
            diveData.participants = participants
        }

        // Equipment - 백엔드 enum → UI 표시용 텍스트 변환
        if hasEquipmentData() {
            diveData.equipment = DiveEquipment(
                suitType: self.suitType != nil ? String.displayName(fromSuitTypeEnum: self.suitType!) : nil,
                Equipment: self.equipment,
                weight: self.weight,
                pweight: self.perceivedWeight != nil ? String.displayName(fromPerceivedWeightEnum: self.perceivedWeight!) : nil
            )
        }

        // Environment - 백엔드 enum → UI 표시용 텍스트 변환
        if hasEnvironmentData() {
            diveData.environment = DiveEnvironment(
                weather: self.weather != nil ? String.displayName(fromWeatherEnum: self.weather!) : nil,
                wind: self.wind != nil ? String.displayName(fromWindEnum: self.wind!) : nil,
                current: self.tide != nil ? String.displayName(fromCurrentEnum: self.tide!) : nil,
                wave: self.wave != nil ? String.displayName(fromWaveEnum: self.wave!) : nil,
                airTemp: self.temperature,
                feelsLike: self.perceivedTemp != nil ? String.displayName(fromFeelsLikeEnum: self.perceivedTemp!) : nil,
                waterTemp: self.waterTemperature,
                visibility: self.sight != nil ? String.displayName(fromVisibilityEnum: self.sight!) : nil
            )
        }

        // Profile
        if hasProfileData() {
            diveData.profile = DiveProfile(
                diveTime: self.diveTime,
                maxDepth: self.maxDepth,
                avgDepth: self.avgDepth,
                decoDepth: self.decompressDepth,  // 추가 (API의 decompressDepth -> UI의 decoDepth)
                decoStop: self.decompressTime,
                startPressure: self.startPressure,
                endPressure: self.finishPressure
            )
        }

        return diveData
    }

    private func hasOverviewData() -> Bool {
        return place != nil ||           // ✅ 추가: place 체크
               divePoint != nil ||
               divePurpose != nil ||
               diveMethod != nil
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
        decompressDepth != nil ||  // 추가
               decompressTime != nil || startPressure != nil || finishPressure != nil
    }
}

// MARK: - DiveLogData → LogUpdateRequestDTO 변환 (UI → 백엔드)
extension DiveLogData {
    func toLogUpdateRequest(with date: Date, saveStatus: SaveStatus) -> LogUpdateRequestDTO {
        let dateString = DateFormatter.apiDateFormatter.string(from: date)

        return LogUpdateRequestDTO(
            date: dateString,
            saveStatus: saveStatus.rawValue,
            place: self.overview?.title,        // TODO: place 별도 필드가 생기면 교체
            divePoint: self.overview?.point,
            // ✅ UI 표시용 텍스트 → 백엔드 enum 변환
            diveMethod: self.overview?.method?.toDivingMethodEnum(),
            divePurpose: self.overview?.purpose?.toDivingPurposeEnum(),
            companions: self.participants?.toCompanionRequestDTOs(), // ✅ 수정된 변환 사용
            // ✅ UI 표시용 텍스트 → 백엔드 enum 변환
            suitType: self.equipment?.suitType?.toSuitTypeEnum(),
            equipment: self.equipment?.Equipment,
            weight: self.equipment?.weight,
            perceivedWeight: self.equipment?.pweight?.toPerceivedWeightEnum(),
            // ✅ UI 표시용 텍스트 → 백엔드 enum 변환
            weather: self.environment?.weather?.toWeatherEnum(),
            wind: self.environment?.wind?.toWindEnum(),
            tide: self.environment?.current?.toCurrentEnum(),
            wave: self.environment?.wave?.toWaveEnum(),
            temperature: self.environment?.airTemp,
            waterTemperature: self.environment?.waterTemp,
            perceivedTemp: self.environment?.feelsLike?.toFeelsLikeEnum(),
            sight: self.environment?.visibility?.toVisibilityEnum(),
            diveTime: self.profile?.diveTime,
            maxDepth: self.profile?.maxDepth,
            avgDepth: self.profile?.avgDepth,
            decompressDepth: self.profile?.decoDepth,            // UI 미사용
            decompressTime: self.profile?.decoStop,
            startPressure: self.profile?.startPressure,
            finishPressure: self.profile?.endPressure,
            consumption: nil                    // UI 미사용
        )
    }
}

// MARK: - DiveParticipants → CompanionRequestDTO 배열 변환 (요청용)
extension DiveParticipants {
    func toCompanionRequestDTOs() -> [CompanionRequestDTO] {
        var result: [CompanionRequestDTO] = []

        // ✅ 리더 추가 - 공백 제거 및 빈 문자열 체크
        if let leader = self.leader?.trimmingCharacters(in: .whitespacesAndNewlines), !leader.isEmpty {
            result.append(CompanionRequestDTO(name: leader, type: "LEADER"))
        }
        
        // ✅ 버디 추가 - 공백 제거 및 빈 문자열 체크
        if let buddy = self.buddy?.trimmingCharacters(in: .whitespacesAndNewlines), !buddy.isEmpty {
            result.append(CompanionRequestDTO(name: buddy, type: "BUDDY"))
        }
        
        // ✅ 동행자들 추가 - 공백 제거 및 빈 문자열 체크
        if let companions = self.companion {
            for name in companions {
                let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmedName.isEmpty {
                    result.append(CompanionRequestDTO(name: trimmedName, type: "COMPANION"))
                }
            }
        }
        
        return result
    }
}
