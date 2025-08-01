//
//  MyOceanViewModel.swift
//  Divary
//
//  Created by 바견규 on 7/25/25.
//

import SwiftUI

@Observable
class CharacterViewModel {
    var customization: CharacterCustomization?

    // 말풍선 입력을 위한 Binding 생성자
    var speechTextBinding: Binding<String> {
        Binding(
            get: { self.customization?.speechText ?? "" },
            set: { newText in
                if let current = self.customization {
                    self.customization = current.copy(speechText: newText)
                }
            }
        )
    }
    
    init(customization: CharacterCustomization) {
        self.customization = customization
    }
    
    

    /// 목데이터용 기본 초기화
    convenience init() {
        self.init(customization: CharacterCustomization(
            CharacterName: "하루",
            background: .coralForest,
            tank: .white,
            pin: .pink,
            regulator: .blue,
            cheek: .pastelPink,
            mask: .yellow,
            body: .gray,
            pet: PetCustomization(
                type: .axolotl,
                offset: CGSize(width: -100, height: 250),
                rotation: .degrees(40)
            ),
            speechBubble: .rectangleTail,
            speechText: "다이빙하러 갈 사람"
            
        ))
    }

    func loadFromJSON() {
        let json = """
        {
            "background": "BackgroundPinkLake",
            "tank": "TankYellow",
            "pin": "PinBlue",
            "regulator": "RegulatorWhite",
            "cheek": "CheekCoral",
            "mask": "MaskPink",
            "body": "CharacterBodyGray",
            "pet": {
                "type": "PetAxolotl",
                "offset": {
                    "width": -20,
                    "height": 15
                },
                "rotation": {
                    "degrees": 10
                }
            }
        }
        """.data(using: .utf8)!

        do {
            let decoded = try JSONDecoder().decode(CharacterCustomization.self, from: json)
            customization = decoded
        } catch {
            print("JSON 디코딩 실패:", error)
        }
    }

    func imageName(for part: String) -> String {
        guard let c = customization else { return "" }

        switch part {
        case "background": return c.background.rawValue
        case "tank": return c.tank.rawValue
        case "pin": return c.pin.rawValue
        case "regulator": return c.regulator.rawValue
        case "cheek": return c.cheek.rawValue
        case "mask": return c.mask.rawValue
        case "body": return c.body.rawValue
        case "pet": return c.pet.type.rawValue
        default: return ""
        }
    }
    
    func updateCharacterName(_ name: String) {
        customization?.CharacterName = name
    }
}
