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
    let secondary = Color(hex: "A4C5CE")
    let accent = Color(hex: "829FBC")
    
    let background = Color(hex: "E0EAE9")
    let surface = Color(UIColor.secondarySystemGroupedBackground)
    
    let success = Color.green
    let warning = Color(hex: "E2B200")
    let danger = Color.red
    let offline = Color.red
    let info = Color.cyan
    
    let textPrimary = Color.primary
    let textSecondary = Color.secondary
}
