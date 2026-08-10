//
//  AlertBannerComponent.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 10/08/26.
//

import SwiftUI

struct AlertBannerComponent: View {
    var title: String
    var message: String
    var timeString: String
    var backgroundColor: Color = Color.theme.primary
    var iconName: String = "exclamationmark.triangle.fill"
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 28))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(message)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text(timeString)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white)
                .padding(.top, 2)
        }
        .padding(16)
        .background(backgroundColor)
        .cornerRadius(12)
    }
}

#Preview {
    ZStack {
        Color.theme.background.ignoresSafeArea()
        
        VStack(spacing: 12) {
            AlertBannerComponent(
                title: "High Humidity",
                message: "Check Sensor Status",
                timeString: "10 minutes ago",
                backgroundColor: Color.theme.primary
            )
            
            AlertBannerComponent(
                title: "Temperature Drop",
                message: "Below ideal threshold",
                timeString: "Just now",
                backgroundColor: Color.theme.warning
            )
            
            AlertBannerComponent(
                title: "Device Offline",
                message: "Connection lost to sensor",
                timeString: "1 hour ago",
                backgroundColor: Color.theme.offline,
                iconName: "wifi.exclamationmark"
            )
        }
        .padding()
    }
}
