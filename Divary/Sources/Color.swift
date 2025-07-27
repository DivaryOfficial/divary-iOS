//
//  Color.swift
//  SOAPFT
//
//  Created by 홍지우 on 6/25/25.
//

import SwiftUI
extension Color {
    
    static let primary_sea_blue     = Color("primary_sea_blue")     // #1392FF
    static let primary_pastel_blue = Color("primary_pastel_blue")   // #94CBFF
    static let primary_sand        = Color("primary_sand")          // #FFEED9

    static let secondary_bl600     = Color("secondary_bl600")       // #0074DA
    static let secondary_pb100     = Color("secondary_pb100")       // #B6E1FF
    static let secondary_sd600     = Color("secondary_sd600")       // #8D725C

    static let grayscale_g900      = Color("grayscale_g900")        // #1A1A1A
    static let grayscale_g800      = Color("grayscale_g800")        // #333333
    static let grayscale_g700      = Color("grayscale_g700")        // #4D4D4D
    static let grayscale_g600      = Color("grayscale_g600")        // #666666
    static let grayscale_g500      = Color("grayscale_g500")        // #808080
    static let grayscale_g400      = Color("grayscale_g400")        // #A4A4A4
    static let grayscale_g300      = Color("grayscale_g300")        // #CCCCCC
    static let grayscale_g200      = Color("grayscale_g200")        // #E5E5E5
    static let grayscale_g100      = Color("grayscale_g100")        // #EDEDED

    static let role_color_postive  = Color("role_color_postive")    // #00D435
    static let role_color_nagative = Color("role_color_nagative")   // #FF5656

    static let bw_black            = Color("b&w_black")             // #121212
    static let bw_white            = Color("b&w_white")             // #FFFFFF

}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
