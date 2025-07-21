//
//  LogBookPageMock.swift
//  Divary
//
//  Created by 바견규 on 7/9/25.
//


let LogBookPageMock: [DiveLogData] = [
    DiveLogData(
        overview: DiveOverview(
            title: "제주도 서귀포시",
            point: "문섬",
            purpose: "펀 다이빙",
            method: "보트"
        ),
        participants: DiveParticipants(
            leader: "김다이버",
            buddy: "이버디",
            companion: ["이동행1", "이동행2","이동행3", "이동행4"]
        ),
        equipment: DiveEquipment(
            suitType: "웻슈트 3mm",
            Equipment: ["BCD", "레귤레이터", "마스크", "다이브 컴퓨터", "다이브 컴퓨터", "다이브 컴퓨터"],
            weight: 6
        ),
        environment: DiveEnvironment(
            weather: "맑음",
            wind: "약함",
            current: "보통",
            wave: "약함",
            airTemp: 27,
            feelsLike: "더움",
            waterTemp: 22,
            visibility: "보통"
        ),
        profile: DiveProfile(
            diveTime: 42,
            maxDepth: 18,
            avgDepth: 12,
            decoStop: 0,
            startPressure: 200,
            endPressure: 50
        )
    ),
    DiveLogData(
        overview: DiveOverview(
            title: "강원도 속초",
            point: "아바이포인트",
            purpose: "교육",
            method: "비치"
        ),
        participants: DiveParticipants(
            leader: "박강사",
            buddy: nil,
            companion: ["초보1"]
        ),
        equipment: DiveEquipment(
            suitType: "드라이슈트",
            Equipment: ["드라이슈트", "후드", "장갑"],
            weight: 4
        ),
        environment: DiveEnvironment(
            weather: "흐림",
            wind: "강함",
            current: "강함",
            wave: "보통",
            airTemp: 20,
            feelsLike: "추움",
            waterTemp: 18,
            visibility: "나쁨"
        ),
        profile: DiveProfile(
            diveTime: 30,
            maxDepth: nil,
            avgDepth: 10,
            decoStop: 5,
            startPressure: 210,
            endPressure: nil
        )
    ),
    DiveLogData(
        overview: nil,
        participants: nil,
        equipment: nil,
        environment: nil,
        profile: nil
    )
]
