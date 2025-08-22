//
//  MyOceanModel.swift
//  Divary
//
//  Created by 바견규 on 7/25/25.
//

import SwiftUI

struct CharacterCustomization: Decodable {
    var CharacterName: String? = nil
    let background: BackgroundType
    let tank: TankType
    let pin: PinType
    let regulator: RegulatorType
    let cheek: CheekType
    let mask: MaskType
    let body: CharacterBodyType
    var pet: PetCustomization
    let speechBubble: SpeechBubbleType
    var speechText: String? = nil
}

//값 변경을 위한 copy 함수
extension CharacterCustomization {
    func copy(
        background: BackgroundType? = nil,
        tank: TankType? = nil,
        pin: PinType? = nil,
        regulator: RegulatorType? = nil,
        cheek: CheekType? = nil,
        mask: MaskType? = nil,
        body: CharacterBodyType? = nil,
        pet: PetCustomization? = nil,
        speechBubble: SpeechBubbleType? = nil,
        CharacterName: String?? = nil,
        speechText: String?? = nil
    ) -> CharacterCustomization {
        return CharacterCustomization(
            CharacterName: CharacterName ?? self.CharacterName,
            background: background ?? self.background,
            tank: tank ?? self.tank,
            pin: pin ?? self.pin,
            regulator: regulator ?? self.regulator,
            cheek: cheek ?? self.cheek,
            mask: mask ?? self.mask,
            body: body ?? self.body,
            pet: pet ?? self.pet,
            speechBubble: speechBubble ?? self.speechBubble,
            speechText: speechText ?? self.speechText
        )
    }
}

enum BackgroundType: String, CaseIterable, Decodable {
    case pinkLake = "BackgroundPinkLake"
    case coralForest = "BackgroundCoralForest"
    case emerald = "BackgroundEmerald"
    case deepSea = "BackgroundDeepSea"
    case none = "none"
    
    // 서버 enum과의 매핑을 위한 computed property
    var serverValue: String {
        switch self {
        case .pinkLake: return "PINK_LAKE"
        case .coralForest: return "CORAL_FOREST"
        case .emerald: return "EMERALD"
        case .deepSea: return "DEEP_SEA"
        case .none: return "CORAL_FOREST" // 기본값
        }
    }
    
    // 서버 값으로부터 클라이언트 enum 생성
    static func fromServerValue(_ serverValue: String?) -> BackgroundType {
        guard let serverValue = serverValue else { return .coralForest }
        
        switch serverValue {
        case "PINK_LAKE": return .pinkLake
        case "CORAL_FOREST": return .coralForest
        case "EMERALD": return .emerald
        case "DEEP_SEA": return .deepSea
        default: return .coralForest
        }
    }
}

enum TankType: String, CaseIterable, Decodable {
    case none = "none"
    case yellow = "TankYellow"
    case green = "TankGreen"
    case white = "TankWhite"
    case blue = "TankBlue"
    case pink = "TankPink"
    
    // 서버 enum과의 매핑
    var serverValue: String? {
        switch self {
        case .none: return nil
        case .yellow: return "YELLOW"
        case .green: return "GREEN"
        case .white: return "WHITE"
        case .blue: return "BLUE"
        case .pink: return "PINK"
        }
    }
    
    static func fromServerValue(_ serverValue: String?) -> TankType {
        guard let serverValue = serverValue else { return .none }
        
        switch serverValue {
        case "YELLOW": return .yellow
        case "GREEN": return .green
        case "WHITE": return .white
        case "BLUE": return .blue
        case "PINK": return .pink
        default: return .none
        }
    }
}

enum PinType: String, CaseIterable, Decodable {
    case none = "none"
    case pink = "PinPink"
    case blue = "PinBlue"
    case white = "PinWhite"
    case yellow = "PinYellow"
    case green = "PinGreen"
    
    var serverValue: String? {
        switch self {
        case .none: return nil
        case .pink: return "PINK"
        case .blue: return "BLUE"
        case .white: return "WHITE"
        case .yellow: return "YELLOW"
        case .green: return "GREEN"
        }
    }
    
    static func fromServerValue(_ serverValue: String?) -> PinType {
        guard let serverValue = serverValue else { return .none }
        
        switch serverValue {
        case "PINK": return .pink
        case "BLUE": return .blue
        case "WHITE": return .white
        case "YELLOW": return .yellow
        case "GREEN": return .green
        default: return .none
        }
    }
}

enum RegulatorType: String, CaseIterable, Decodable {
    case none = "none"
    case green = "RegulatorGreen"
    case white = "RegulatorWhite"
    case pink = "RegulatorPink"
    case blue = "RegulatorBlue"
    case yellow = "RegulatorYellow"
    
    var serverValue: String? {
        switch self {
        case .none: return nil
        case .green: return "GREEN"
        case .white: return "WHITE"
        case .pink: return "PINK"
        case .blue: return "BLUE"
        case .yellow: return "YELLOW"
        }
    }
    
    static func fromServerValue(_ serverValue: String?) -> RegulatorType {
        guard let serverValue = serverValue else { return .none }
        
        switch serverValue {
        case "GREEN": return .green
        case "WHITE": return .white
        case "PINK": return .pink
        case "BLUE": return .blue
        case "YELLOW": return .yellow
        default: return .none
        }
    }
}

enum CheekType: String, CaseIterable, Decodable {
    case none = "none"
    case salmon = "CheekSalmon"
    case orange = "CheekOrange"
    case coral = "CheekCoral"
    case pink = "CheekPeach"
    case peach = "CheekPastelPink"
    
    
    var serverValue: String? {
        switch self {
        case .none: return nil
        case .salmon: return "SALMON"
        case .orange: return "ORANGE"
        case .coral: return "CORAL"
        case .pink: return "PINK"
        case .peach: return "PEACH"
        }
    }
    
    static func fromServerValue(_ serverValue: String?) -> CheekType {
        guard let serverValue = serverValue else { return .none }
        
        switch serverValue {
        case "PEACH": return .peach
        case "CORAL": return .coral
        case "SALMON": return .salmon
        case "ORANGE": return .orange
        case "PINK": return .pink
        default: return .pink  // MARK: - 수정
        }
    }
}

enum MaskType: String, CaseIterable, Decodable {
    case none = "none"
    case pink = "MaskPink"
    case blue = "MaskBlue"
    case green = "MaskGreen"
    case white = "MaskWhite"
    case yellow = "MaskYellow"
    
    var serverValue: String? {
        switch self {
        case .none: return nil
        case .pink: return "PINK"
        case .blue: return "BLUE"
        case .green: return "GREEN"
        case .white: return "WHITE"
        case .yellow: return "YELLOW"
        }
    }
    
    static func fromServerValue(_ serverValue: String?) -> MaskType {
        guard let serverValue = serverValue else { return .none }
        
        switch serverValue {
        case "WHITE": return .white
        case "GREEN": return .green
        case "PINK": return .pink
        case "BLUE": return .blue
        case "YELLOW": return .yellow
        default: return .none
        }
    }
}

enum CharacterBodyType: String, CaseIterable, Decodable {
    case ivory = "CharacterBodyIvory"
    case cream = "CharacterBodyYellow"
    case pink = "CharacterBodyPink"
    case brown = "CharacterBodyBrown"
    case gray = "CharacterBodyGray"
    case none = "none"
    
    var serverValue: String {
        switch self {
        case .ivory: return "IVORY"
        case .cream: return "CREAM"
        case .pink: return "PINK"
        case .brown: return "BROWN"
        case .gray: return "GRAY"
        case .none: return "IVORY" // 기본값
        }
    }
    
    static func fromServerValue(_ serverValue: String?) -> CharacterBodyType {
        guard let serverValue = serverValue else { return .ivory }
        
        switch serverValue {
        case "IVORY": return .ivory
        case "CREAM": return .cream
        case "PINK": return .pink
        case "BROWN": return .brown
        case "GRAY": return .gray
        default: return .ivory
        }
    }
}

enum SpeechBubbleType: String, CaseIterable, Decodable {
    case none = "none"
    case roundSquare = "SpeechBubbleRectangle"
    case rectangleTail = "rectangleTail"
    case roundedTail = "roundedTail"
    case thought = "SpeechBubbleThought"
    
    var serverValue: String? {
        switch self {
        case .none: return nil
        case .roundSquare: return "ROUND_SQUARE"
        case .rectangleTail: return "ROUND_SQUARE_TAILED"
        case .roundedTail: return "OVAL_TAILED"
        case .thought: return "OVAL_CIRCLE_TAILED"
        }
    }
    
    static func fromServerValue(_ serverValue: String?) -> SpeechBubbleType {
        guard let serverValue = serverValue else { return .none }
        
        switch serverValue {
        case "ROUND_SQUARE": return .roundSquare
        case "ROUND_SQUARE_TAILED": return .rectangleTail
        case "OVAL_TAILED": return .roundedTail
        case "OVAL_CIRCLE_TAILED": return .thought
        default: return .none
        }
    }
    
    func view(text: String, binding: Binding<String>? = nil) -> some View {
        switch self {
        case .roundSquare:
            return AnyView(RectangleSpeechBubble(text: text))
        case .rectangleTail:
            return AnyView(RectangleTailSpeechBubbleView(text: text))
        case .roundedTail:
            return AnyView(RoundedTailSpeechBubbleView(text: text))
        case .thought:
            return AnyView(ThoughtSpeechBubbleView(text: text))
        case .none:
            return AnyView(EmptyView())
        }
    }
    
    func inputView(text: Binding<String>) -> some View {
        switch self {
        case .roundSquare:
            return AnyView(RectangleSpeechBubbleInput(text: text))
        case .rectangleTail:
            return AnyView(RectangleTailSpeechBubbleInputView(text: text))
        case .roundedTail:
            return AnyView(RoundedTailSpeechBubbleInputView(text: text))
        case .thought:
            return AnyView(ThoughtSpeechBubbleInputView(text: text))
        case .none:
            return AnyView(EmptyView())
        }
    }
}

extension SpeechBubbleType {
    var defaultImageName: String {
        switch self {
        case .none: return "noneDefault"
        case .roundSquare: return "RectangleSpeechBubbleDefault"
        case .rectangleTail: return "RectangleTailSpeechBubbleDefault"
        case .roundedTail: return "RoundedTailSpeechBubbleDefault"
        case .thought: return "ThoughtSpeechBubbleDefault"
        }
    }
    
    var clickedImageName: String {
        switch self {
        case .none: return "noneClicked"
        case .roundSquare: return "RectangleSpeechBubbleClicked"
        case .rectangleTail: return "RectangleTailSpeechBubbleClicked"
        case .roundedTail: return "RoundedTailSpeechBubbleClicked"
        case .thought: return "ThoughtSpeechBubbleClicked"
        }
    }
}

struct PetCustomization: Decodable {
    let type: PetType
    var offset: CGSize
    var rotation: Angle

    enum CodingKeys: String, CodingKey {
        case type, offset, rotation
    }

    enum OffsetKeys: String, CodingKey {
        case width, height
    }

    enum RotationKeys: String, CodingKey {
        case degrees
    }

    init(type: PetType, offset: CGSize = .zero, rotation: Angle = .zero) {
        self.type = type
        self.offset = offset
        self.rotation = rotation
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(PetType.self, forKey: .type)

        let offsetContainer = try container.nestedContainer(keyedBy: OffsetKeys.self, forKey: .offset)
        let width = try offsetContainer.decode(CGFloat.self, forKey: .width)
        let height = try offsetContainer.decode(CGFloat.self, forKey: .height)
        self.offset = CGSize(width: width, height: height)

        let rotationContainer = try container.nestedContainer(keyedBy: RotationKeys.self, forKey: .rotation)
        let degrees = try rotationContainer.decode(Double.self, forKey: .degrees)
        self.rotation = .degrees(degrees)
    }
}

enum PetType: String, CaseIterable, Decodable {
    case expectedGray = "PetExpectedGray"
    case expectedBlue = "PetExpectedBlue"
    case none = "none"
    case hermitCrab = "PetHermitCrab"
    case seahorse = "PetSeahorse"
    case axolotl = "PetAxolotl"
    case anglerFish = "PetAnglerFish"
    
    var serverValue: String? {
        switch self {
        case .none: return nil
        case .hermitCrab: return "HERMIT_CRAB"
        case .seahorse: return "SEAHORSE"
        case .axolotl: return "AXOLOTL"
        case .anglerFish: return "ANGLERFISH"
        case .expectedGray, .expectedBlue: return "COMING_SOON"
        }
    }
    
    static func fromServerValue(_ serverValue: String?) -> PetType {
        guard let serverValue = serverValue else { return .none }
        
        switch serverValue {
        case "HERMIT_CRAB": return .hermitCrab
        case "SEAHORSE": return .seahorse
        case "AXOLOTL": return .axolotl
        case "ANGLERFISH": return .anglerFish
        case "COMING_SOON": return .expectedGray
        default: return .none
        }
    }
}
