//
//  Mock.swift
//  Divary
//
//  Created by chohaeun on 8/5/25.
//

// MockData.swift - 새 파일 생성

import Foundation

// 로그북베이스를 시뮬레이션하는 구조체 (기존 모델 건드리지 않음)
struct LogBookBaseMock {
    let id: String
    let date: Date
    let title: String
    let iconType: IconType
    let logBooks: [DiveLogData] // 최대 3개
}

// 테스트용 목데이터
let LogBookBaseMockData: [LogBookBaseMock] = [
    LogBookBaseMock(
        id: "log_base_1",
        date: DateComponents(calendar: .current, year: 2025, month: 7, day: 27).date!,
        title: "제주도 서귀포 다이빙",
        iconType: .blowfish,
        logBooks: [
            DiveLogData(
                overview: DiveOverview(
                    title: "제주도 서귀포시 1차",
                    point: "문섬",
                    purpose: "펀 다이빙",
                    method: "보트"
                ),
                participants: DiveParticipants(
                    leader: "김다이버",
                    buddy: "이버디",
                    companion: ["이동행1", "이동행2"]
                ),
                equipment: DiveEquipment(
                    suitType: "웻슈트 3mm",
                    Equipment: ["BCD", "레귤레이터", "마스크"],
                    weight: 6
                ),
                environment: DiveEnvironment(
                    weather: "맑음",
                    wind: "약함",
                    current: "보통",
                    wave: "약함",
                    airTemp: 27,
                    waterTemp: 22
                ),
                profile: DiveProfile(
                    diveTime: 42,
                    maxDepth: 18,
                    avgDepth: 12,
                    startPressure: 200,
                    endPressure: 50
                )
            ),
            DiveLogData(
                overview: DiveOverview(
                    title: "제주도 서귀포시 2차",
                    point: "범섬",
                    purpose: "수중촬영",
                    method: "보트"
                ),
                participants: DiveParticipants(
                    leader: "김다이버",
                    buddy: "이버디",
                    companion: ["사진작가"]
                ),
                equipment: DiveEquipment(
                    suitType: "웻슈트 3mm",
                    Equipment: ["BCD", "레귤레이터", "수중카메라"],
                    weight: 7
                ),
                environment: DiveEnvironment(
                    weather: "맑음",
                    wind: "약함",
                    current: "약함",
                    wave: "약함",
                    airTemp: 28,
                    waterTemp: 23
                ),
                profile: DiveProfile(
                    diveTime: 38,
                    maxDepth: 15,
                    avgDepth: 10,
                    startPressure: 200,
                    endPressure: 60
                )
            ),
            // 3번째는 빈 로그 (새로 작성할 수 있도록)
            DiveLogData()
        ]
    ),
    LogBookBaseMock(
        id: "log_base_2",
        date: DateComponents(calendar: .current, year: 2025, month: 7, day: 17).date!,
        title: "속초 아바이포인트",
        iconType: .octopus,
        logBooks: [
            DiveLogData(
                overview: DiveOverview(
                    title: "속초 야간다이빙",
                    point: "아바이포인트",
                    purpose: "야간탐사",
                    method: "비치"
                ),
                participants: DiveParticipants(
                    leader: "박강사",
                    buddy: "최버디",
                    companion: ["야간러버"]
                ),
                equipment: DiveEquipment(
                    suitType: "드라이슈트",
                    Equipment: ["BCD", "랜턴", "후드"],
                    weight: 8
                ),
                environment: DiveEnvironment(
                    weather: "맑음",
                    wind: "보통",
                    current: "강함",
                    wave: "보통",
                    airTemp: 20,
                    waterTemp: 18
                ),
                profile: DiveProfile(
                    diveTime: 35,
                    maxDepth: 12,
                    avgDepth: 8,
                    startPressure: 210,
                    endPressure: 70
                )
            ),
            DiveLogData(), // 빈 로그
            DiveLogData()  // 빈 로그
        ]
    ),
    LogBookBaseMock(
        id: "log_base_3",
        date: DateComponents(calendar: .current, year: 2025, month: 6, day: 28).date!,
        title: "울진 죽변항",
        iconType: .clownfish,
        logBooks: [
            DiveLogData(
                overview: DiveOverview(
                    title: "울진 죽변항 체험",
                    point: "죽변항 앞바다",
                    purpose: "체험다이빙",
                    method: "보트"
                ),
                participants: DiveParticipants(
                    leader: "이교관",
                    buddy: nil,
                    companion: ["체험자1", "체험자2"]
                ),
                equipment: DiveEquipment(
                    suitType: "웻슈트 5mm",
                    Equipment: ["BCD", "레귤레이터"],
                    weight: 5
                ),
                environment: DiveEnvironment(
                    weather: "흐림",
                    wind: "강함",
                    current: "약함",
                    wave: "강함",
                    airTemp: 25,
                    waterTemp: 20
                ),
                profile: DiveProfile(
                    diveTime: 25,
                    maxDepth: 8,
                    avgDepth: 6,
                    startPressure: 200,
                    endPressure: 100
                )
            ),
            DiveLogData(), // 빈 로그
            DiveLogData()  // 빈 로그
        ]
    )
]

// 기존 LogBookPageMock을 특정 logBaseId에 따라 반환하는 함수
func getLogBooksForBase(logBaseId: String) -> [DiveLogData] {
    return LogBookBaseMockData.first { $0.id == logBaseId }?.logBooks ?? [DiveLogData(), DiveLogData(), DiveLogData()]
}
