//
//  DiveEnums.swift
//  Divary
//
//  Created by chohaeun on 8/12/25.
//

import Foundation

// MARK: - Environment Enums

enum WeatherType: String, CaseIterable {
    case sunny = "SUNNY"
    case partlyCloudy = "PARTLY_CLOUDY"
    case cloudy = "CLOUDY"
    case rainy = "RAINY"
    
    var displayName: String {
        switch self {
        case .sunny: return "맑음"
        case .partlyCloudy: return "약간 흐림"
        case .cloudy: return "흐림"
        case .rainy: return "비"
        }
    }
    
    static var allDisplayNames: [String] {
        return Self.allCases.map { $0.displayName }
    }
    
    static func from(displayName: String) -> WeatherType? {
        return Self.allCases.first { $0.displayName == displayName }
    }
}

enum WindType: String, CaseIterable {
    case light = "LIGHT"
    case moderate = "MODERATE"
    case strong = "STRONG"
    case veryStrong = "VERY_STRONG"
    
    var displayName: String {
        switch self {
        case .light: return "약풍"
        case .moderate: return "중풍"
        case .strong: return "강풍"
        case .veryStrong: return "폭풍"
        }
    }
    
    static var allDisplayNames: [String] {
        return Self.allCases.map { $0.displayName }
    }
    
    static func from(displayName: String) -> WindType? {
        return Self.allCases.first { $0.displayName == displayName }
    }
}

enum CurrentType: String, CaseIterable {
    case none = "NONE"
    case weak = "WEAK"
    case moderate = "MODERATE"
    case strong = "STRONG"
    
    var displayName: String {
        switch self {
        case .none: return "없음"
        case .weak: return "미류"
        case .moderate: return "중류"
        case .strong: return "격류"
        }
    }
    
    static var allDisplayNames: [String] {
        return Self.allCases.map { $0.displayName }
    }
    
    static func from(displayName: String) -> CurrentType? {
        return Self.allCases.first { $0.displayName == displayName }
    }
}

enum WaveType: String, CaseIterable {
    case calm = "CALM"
    case moderate = "MODERATE"
    case rough = "ROUGH"
    
    var displayName: String {
        switch self {
        case .calm: return "약함"
        case .moderate: return "중간"
        case .rough: return "강함"
        }
    }
    
    static var allDisplayNames: [String] {
        return Self.allCases.map { $0.displayName }
    }
    
    static func from(displayName: String) -> WaveType? {
        return Self.allCases.first { $0.displayName == displayName }
    }
}

enum FeelsLikeType: String, CaseIterable {
    case cold = "COLD"
    case moderate = "MEDIUM"
    case hot = "HOT"
    
    var displayName: String {
        switch self {
        case .cold: return "추움"
        case .moderate: return "보통"
        case .hot: return "더움"
        }
    }
    
    static var allDisplayNames: [String] {
        return Self.allCases.map { $0.displayName }
    }
    
    static func from(displayName: String) -> FeelsLikeType? {
        return Self.allCases.first { $0.displayName == displayName }
    }
}

enum VisibilityType: String, CaseIterable {
    case good = "GOOD"
    case fair = "FAIR"
    case poor = "POOR"
    
    var displayName: String {
        switch self {
        case .good: return "좋음"
        case .fair: return "보통"
        case .poor: return "나쁨"
        }
    }
    
    static var allDisplayNames: [String] {
        return Self.allCases.map { $0.displayName }
    }
    
    static func from(displayName: String) -> VisibilityType? {
        return Self.allCases.first { $0.displayName == displayName }
    }
}

// MARK: - Equipment Enums

enum SuitType: String, CaseIterable {
    case wetsuit3mm = "WETSUIT_3MM"
    case wetsuit5mm = "WETSUIT_5MM"
    case drysuit = "DRYSUIT"
    case other = "OTHER"
    
    var displayName: String {
        switch self {
        case .wetsuit3mm: return "웻슈트 3mm"
        case .wetsuit5mm: return "웻슈트 5mm"
        case .drysuit: return "드라이 슈트"
        case .other: return "기타"
        }
    }
    
    static var allDisplayNames: [String] {
        return Self.allCases.map { $0.displayName }
    }
    
    static func from(displayName: String) -> SuitType? {
        return Self.allCases.first { $0.displayName == displayName }
    }
}

enum PerceivedWeightType: String, CaseIterable {
    case light = "LIGHT"
    case moderate = "NORMAL"
    case heavy = "HEAVY"
    
    var displayName: String {
        switch self {
        case .light: return "가벼움"
        case .moderate: return "보통"
        case .heavy: return "무거움"
        }
    }
    
    static var allDisplayNames: [String] {
        return Self.allCases.map { $0.displayName }
    }
    
    static func from(displayName: String) -> PerceivedWeightType? {
        return Self.allCases.first { $0.displayName == displayName }
    }
}

// MARK: - Overview Enums

enum DivingMethodType: String, CaseIterable {
    case shore = "SHORE"
    case boat = "BOAT"
    case other = "OTHER"
    
    var displayName: String {
        switch self {
        case .shore: return "비치"
        case .boat: return "보트"
        case .other: return "기타"
        }
    }
    
    static var allDisplayNames: [String] {
        return Self.allCases.map { $0.displayName }
    }
    
    static func from(displayName: String) -> DivingMethodType? {
        return Self.allCases.first { $0.displayName == displayName }
    }
}

enum DivingPurposeType: String, CaseIterable {
    case fun = "FUN"
    case training = "TRAINING"
    
    var displayName: String {
        switch self {
        case .fun: return "펀 다이빙"
        case .training: return "교육 다이빙"
        }
    }
    
    static var allDisplayNames: [String] {
        return Self.allCases.map { $0.displayName }
    }
    
    static func from(displayName: String) -> DivingPurposeType? {
        return Self.allCases.first { $0.displayName == displayName }
    }
}

// MARK: - Utility Extensions

extension String {
    // 백엔드로 보낼 때 enum 값으로 변환하는 헬퍼 메서드들
    func toWeatherEnum() -> String? {
        return WeatherType.from(displayName: self)?.rawValue
    }
    
    func toWindEnum() -> String? {
        return WindType.from(displayName: self)?.rawValue
    }
    
    func toCurrentEnum() -> String? {
        return CurrentType.from(displayName: self)?.rawValue
    }
    
    func toWaveEnum() -> String? {
        return WaveType.from(displayName: self)?.rawValue
    }
    
    func toFeelsLikeEnum() -> String? {
        return FeelsLikeType.from(displayName: self)?.rawValue
    }
    
    func toVisibilityEnum() -> String? {
        return VisibilityType.from(displayName: self)?.rawValue
    }
    
    func toSuitTypeEnum() -> String? {
        return SuitType.from(displayName: self)?.rawValue
    }
    
    func toPerceivedWeightEnum() -> String? {
        return PerceivedWeightType.from(displayName: self)?.rawValue
    }
    
    func toDivingMethodEnum() -> String? {
        return DivingMethodType.from(displayName: self)?.rawValue
    }
    
    func toDivingPurposeEnum() -> String? {
        return DivingPurposeType.from(displayName: self)?.rawValue
    }
}

// 백엔드에서 받은 enum 값을 UI 표시용 텍스트로 변환하는 헬퍼 메서드들
extension String {
    static func displayName(fromWeatherEnum value: String) -> String? {
        return WeatherType(rawValue: value)?.displayName
    }
    
    static func displayName(fromWindEnum value: String) -> String? {
        return WindType(rawValue: value)?.displayName
    }
    
    static func displayName(fromCurrentEnum value: String) -> String? {
        return CurrentType(rawValue: value)?.displayName
    }
    
    static func displayName(fromWaveEnum value: String) -> String? {
        return WaveType(rawValue: value)?.displayName
    }
    
    static func displayName(fromFeelsLikeEnum value: String) -> String? {
        return FeelsLikeType(rawValue: value)?.displayName
    }
    
    static func displayName(fromVisibilityEnum value: String) -> String? {
        return VisibilityType(rawValue: value)?.displayName
    }
    
    static func displayName(fromSuitTypeEnum value: String) -> String? {
        return SuitType(rawValue: value)?.displayName
    }
    
    static func displayName(fromPerceivedWeightEnum value: String) -> String? {
        return PerceivedWeightType(rawValue: value)?.displayName
    }
    
    static func displayName(fromDivingMethodEnum value: String) -> String? {
        return DivingMethodType(rawValue: value)?.displayName
    }
    
    static func displayName(fromDivingPurposeEnum value: String) -> String? {
        return DivingPurposeType(rawValue: value)?.displayName
    }
}
