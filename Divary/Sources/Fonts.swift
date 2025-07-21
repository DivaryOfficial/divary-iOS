//
//  Fonts.swift
//  Starbucks
//
//  Created by 박현규 on 3/19/25.
//

import Foundation
import SwiftUI

extension Font {
    enum omyu: String {
        case regular = "omyu_pretty"
        
        
        var value: String {
            return self.rawValue
        }
        
        // 함수로 변경하여 크기 조정 가능하도록 수정
        static func regular(size: CGFloat) -> Font {
            return DivaryFontFamily.OmyuPretty.regular.swiftUIFont(size: size)
        }
        
        
    }
       
       enum NanumSquareNeo: String {
           case extraBold = "NanumSquareNeoTTF-dEb"
           case bold = "NanumSquareNeoTTF-cBd"
           case heavy = "NanumSquareNeoTTF-eHv"
           case regular = "NanumSquareNeoTTF-bRg"
           case light = "NanumSquareNeoTTF-aLt"
           
           var value: String {
               return self.rawValue
           }
       
       
       // 함수로 변경하여 크기 조정 가능하도록 수정
       static func NanumSquareNeoLight(size: CGFloat) -> Font {
           return DivaryFontFamily.NanumSquareNeo.light.swiftUIFont(size: size)
       }
       
       static func NanumSquareNeoExtraBold(size: CGFloat) -> Font {
           return DivaryFontFamily.NanumSquareNeo.extraBold.swiftUIFont(size: size)
       }
       
       static func NanumSquareNeoHeavy(size: CGFloat) -> Font {
           return DivaryFontFamily.NanumSquareNeo.heavy.swiftUIFont(size: size)
       }
           
        static func NanumSquareNeoBold(size: CGFloat) -> Font {
            return DivaryFontFamily.NanumSquareNeo.bold.swiftUIFont(size: size)
        }
       
       static func NanumSquareNeoRegular(size: CGFloat) -> Font {
           return DivaryFontFamily.NanumSquareNeo.regular.swiftUIFont(size: size)
       }
   
   }
}



