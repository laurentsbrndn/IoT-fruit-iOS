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
        case .offline: return Color.theme.offline
        case .warning: return Color.yellow
        case .ideal: return Color.green
        case .delivered: return Color.blue
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
    
    var size: BadgeSize = .large
    
    enum BadgeSize {
        case small
        case large
        
        var iconFont: Font {
            self == .small ? .system(size: 12, weight: .bold) : .system(size: 28)
        }
        var textFont: Font {
            self == .small ? .system(size: 13, weight: .semibold) : .system(size: 28, weight: .medium)
        }
        var spacing: CGFloat {
            self == .small ? 6 : 12
        }
        var horizontalPadding: CGFloat {
            self == .small ? 12 : 24
        }
        var verticalPadding: CGFloat {
            self == .small ? 8 : 12
        }
    }
    
    var body: some View {
        HStack(spacing: size.spacing) {
            Text(status.title)
                .font(size.textFont)
        }
        .foregroundColor(.white)
        .padding(.horizontal, size.horizontalPadding)
        .padding(.vertical, size.verticalPadding)
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
