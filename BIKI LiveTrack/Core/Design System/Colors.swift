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
    let primaryGreen = Color(hex: "33613D") // tulisan ideal
    
    let tertiaryGreen = Color(hex: "E0EAE9") // bg
    let surface = Color(UIColor.secondarySystemGroupedBackground)
    
    let secondaryGreen = Color(hex: "B9E5C2") // bg ideal
    let secondaryYellow = Color(hex: "FFF4CD") // bg warning
    let primaryYellow = Color(hex: "C09804") // tulisan warning
    let primaryRed = Color(hex: "D50408") // tulisan offline
    let secondaryRed = Color(hex: "FFC5C6") // bg offline
    let grey = Color(hex: "D0D0D0") // offline card
    let lightGreen = Color(hex: "F8FDF9") // table row 2 (row 1nya white) - dot yg update itu pake .cyan
    let FrameCard = Color(hex: "EFF2F2")
    
    let textPrimary = Color.primary
    let textSecondary = Color.secondary
}
