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
    let pet: PetCustomization
    let userName: String?
}


enum BackgroundType: String, CaseIterable, Decodable {
    case pinkLake = "BackgroundPinkLake"
    case coralForest = "BackgroundCoralForest"
    case shipWreck = "BackgroundShipWreck"
    case emerald = "BackgroundEmerald"
    case none = "none"
}

enum TankType: String, CaseIterable, Decodable {
    case yellow = "TankYellow"
    case green = "TankGreen"
    case white = "TankWhite"
    case blue = "TankBlue"
    case pink = "TankPink"
    case none = "none"
}

enum PinType: String, CaseIterable, Decodable {
    case pink = "PinPink"
    case blue = "PinBlue"
    case white = "PinWhite"
    case yellow = "PinYellow"
    case green = "PinGreen"
    case none = "none"
}

enum RegulatorType: String, CaseIterable, Decodable {
    case green = "RegulatorGreen"
    case white = "RegulatorWhite"
    case pink = "RegulatorPink"
    case blue = "RegulatorBlue"
    case yellow = "RegulatorYellow"
    case none = "none"
}

enum CheekType: String, CaseIterable, Decodable {
    case pastelPink = "CheekPastelPink"
    case salmon = "CheekSalmon"
    case pink = "CheekPink"
    case coral = "CheekCoral"
    case orange = "CheekOrange"
    case none = "none"
}

enum MaskType: String, CaseIterable, Decodable {
    case pink = "MaskPink"
    case blue = "MaskBlue"
    case green = "MaskGreen"
    case white = "MaskWhite"
    case yellow = "MaskYellow"
    case none = "none"
}

enum CharacterBodyType: String, CaseIterable, Decodable {
    case yellow = "CharacterBodyYellow"
    case pink = "CharacterBodyPink"
    case gray = "CharacterBodyGray"
    case ivory = "CharacterBodyIvory"
    case brown = "CharacterBodyBrown"
    case none = "none"
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
    case seahorse = "PetSeahorse"
    case axolotl = "PetAxolotl"
    case whale = "PetWhale"
    case hermitCrab = "PetHermitCrab"
    case none = "none"
}
