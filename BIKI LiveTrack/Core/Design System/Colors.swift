//
//  Colors.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 06/08/26.
//

import SwiftUI

extension Color {
    static let theme = AppTheme()
}

struct AppTheme {
    // Brand Colors
    let primary = Color.blue
    let secondary = Color.indigo
    
    // Backgrounds
    let background = Color(UIColor.systemGroupedBackground)
    let surface = Color(UIColor.secondarySystemGroupedBackground)
    
    // Semantic Colors (Untuk Status / Alert)
    let success = Color.green
    let warning = Color.orange
    let danger = Color.red
    let info = Color.cyan
    
    // Text Colors
    let textPrimary = Color.primary
    let textSecondary = Color.secondary
}
