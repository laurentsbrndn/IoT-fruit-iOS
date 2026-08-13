//
//  StatusBadgeComponent.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 11/08/26.
//

import SwiftUI

enum DeviceStatus {
    case offline
    case warning
    case ideal
    
    var title: String {
        switch self {
        case .offline: return "Offline"
        case .warning: return "Warning"
        case .ideal: return "Ideal"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .offline: return Color.theme.secondaryRed
        case .warning: return Color.theme.secondaryYellow
        case .ideal: return Color.theme.secondaryGreen
        }
    }

    var foregroundColor: Color {
        switch self {
        case .offline: return Color.theme.primaryRed
        case .warning: return Color.theme.primaryYellow
        case .ideal :  return Color.theme.primaryGreen
        }
    }
    
    static func from(category: String, title: String) -> DeviceStatus {
        switch category.lowercased() {
        case "offline":
            return .offline
        case "warning":
            return .warning
        case "ideal":
            return .ideal
        default:
            return .ideal
        }
    }
}
struct StatusBadgeComponent: View {
    let status: DeviceStatus    
    var body: some View {
        Text(status.title)
        .font(.app.bodyBold)
        .padding(.horizontal, 28)
        .padding(.vertical, 2)
        .foregroundColor(status.foregroundColor)
        .background(status.backgroundColor)
        .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 20) {
        StatusBadgeComponent(status: .offline)
        StatusBadgeComponent(status: .warning)
        StatusBadgeComponent(status: .ideal)
    }
    .padding()
}
