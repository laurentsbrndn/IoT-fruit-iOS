//
//  Colors.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 06/08/26.
//

import SwiftUI

extension Color {
    static let theme = AppTheme()
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct AppTheme {
    let primary = Color(hex: "33613D")
    
    let background = Color(hex: "E0EAE9")
    let surface = Color(UIColor.secondarySystemGroupedBackground)
    
    let pillideal = Color(hex: "B9E5C2")
    let warning = Color(hex: "C09804")
    let offline = Color(hex: "D50408")
    let offlinecard = Color(hex: "D0D0D0")
    let TableRow1 = Color.white
    let TableRow2 = Color(hex: "F8FDF9")
    let Update = Color.cyan
    let FrameCard = Color(hex: "EFF2F2")
    
    let textPrimary = Color.primary
    let textSecondary = Color.secondary
}
