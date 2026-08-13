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
    case delivered
    
    var title: String {
        switch self {
        case .offline: return "Offline"
        case .warning: return "Warning"
        case .ideal: return "Ideal"
        case .delivered: return "Delivered"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .offline: return Color.theme.secondaryRed
        case .warning: return Color.theme.secondaryYellow
        case .ideal: return Color.theme.secondaryGreen
        case .delivered: return Color.theme.secondaryGreen
        }
    }

    var foregroundColor: Color {
        switch self {
        case .offline: return Color.theme.primaryRed
        case .warning: return Color.theme.primaryYellow
        case .ideal, .delivered: return Color.theme.primaryGreen
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
    // Kept for compatibility with existing callers. Both sizes intentionally
    // use the SensorCardShipmentHistoryComponent pill style.
    var size: BadgeSize = .large

    enum BadgeSize {
        case small
        case large
    }
    
    var body: some View {
        Text(status.title)
        .font(.system(size: 16, weight: .semibold))
        .tracking(-0.31)
        .padding(.horizontal, 12)
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
