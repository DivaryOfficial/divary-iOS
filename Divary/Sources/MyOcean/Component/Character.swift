//
//  Character.swift
//  Divary
//
//  Created by 바견규 on 8/13/25.
//

import SwiftUI

// MARK: - 캐릭터 장비 뷰
struct CharacterEquipmentView: View {
    let customization: CharacterCustomization
    let scale: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    var body: some View {
        ZStack {
            // 산소통
            if customization.tank != .none {
                Image(customization.tank.rawValue)
                    .scaleEffect(scale)
                    .offset(x: (70 * scale) + x, y: (-10 * scale) + y)
            }
            
            // 몸통 (기본으로 항상 표시)
            if customization.body != .none {
                Image(customization.body.rawValue)
                    .scaleEffect(scale)
                    .offset(x: x, y: y)
            }
            
            // 호흡기
            if customization.regulator != .none {
                Image(customization.regulator.rawValue)
                    .scaleEffect(scale)
                    .offset(x: (-65 * scale) + x, y: (-30 * scale) + y)
            }
            
            // 볼터치
            if customization.cheek != .none {
                Image(customization.cheek.rawValue)
                    .scaleEffect(scale)
                    .offset(x: (-45 * scale) + x, y: (-40 * scale) + y)
            }
            
            // 마스크
            if customization.mask != .none {
                Image(customization.mask.rawValue)
                    .scaleEffect(scale)
                    .offset(x: (-28 * scale) + x, y: (-60 * scale) + y)
            }
            
            // 핀
            if customization.pin != .none {
                Image(customization.pin.rawValue)
                    .scaleEffect(scale)
                    .offset(x: (68 * scale) + x, y: (85 * scale) + y)
            }
        }
    }
}
