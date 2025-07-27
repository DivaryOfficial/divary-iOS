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
    case shipWreck = "BackgroundShipWreck"
    case emerald = "BackgroundEmerald"
    case none = "none"
}

enum TankType: String, CaseIterable, Decodable {
    case none = "none"
    case yellow = "TankYellow"
    case green = "TankGreen"
    case white = "TankWhite"
    case blue = "TankBlue"
    case pink = "TankPink"
}

enum PinType: String, CaseIterable, Decodable {
    case none = "none"
    case pink = "PinPink"
    case blue = "PinBlue"
    case white = "PinWhite"
    case yellow = "PinYellow"
    case green = "PinGreen"
}

enum RegulatorType: String, CaseIterable, Decodable {
    case none = "none"
    case green = "RegulatorGreen"
    case white = "RegulatorWhite"
    case pink = "RegulatorPink"
    case blue = "RegulatorBlue"
    case yellow = "RegulatorYellow"
}

enum CheekType: String, CaseIterable, Decodable {
    case pastelPink = "CheekPastelPink"
    case salmon = "CheekSalmon"
    case orange = "CheekOrange"
    case coral = "CheekCoral"
    case pink = "CheekPink"
    case none = "none"
}

enum MaskType: String, CaseIterable, Decodable {
    case none = "none"
    case pink = "MaskPink"
    case blue = "MaskBlue"
    case green = "MaskGreen"
    case white = "MaskWhite"
    case yellow = "MaskYellow"
}

enum CharacterBodyType: String, CaseIterable, Decodable {
    case ivory = "CharacterBodyIvory"
    case yellow = "CharacterBodyYellow"
    case pink = "CharacterBodyPink"
    case brown = "CharacterBodyBrown"
    case gray = "CharacterBodyGray"
    case none = "none"
}

enum SpeechBubbleType: String, CaseIterable, Decodable {
    case none = "none"
    case rectangle = "SpeechBubbleRectangle"
    case rectangleTail = "rectangleTail"
    case roundedTail = "roundedTail"
    case thought = "SpeechBubbleThought"
    
    func view(text: String, binding: Binding<String>? = nil) -> some View {
        switch self {
        case .rectangle:
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
        case .rectangle:
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
        case .rectangle: return "RectangleSpeechBubbleDefault"
        case .rectangleTail: return "RectangleTailSpeechBubbleDefault"
        case .roundedTail: return "RoundedTailSpeechBubbleDefault"
        case .thought: return "ThoughtSpeechBubbleDefault"
        }
    }
    
    var clickedImageName: String {
        switch self {
        case .none: return "noneClicked"
        case .rectangle: return "RectangleSpeechBubbleClicked"
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
    case whale = "PetWhale"
    
   
}
