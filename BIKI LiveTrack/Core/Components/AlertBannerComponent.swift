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
    var iconName: String = "bell.fill"
    var backgroundColor: Color = Color.theme.primaryGreen.opacity(0.1)
    var iconColor: Color = Color.theme.primaryGreen
    var textColor: Color = Color.theme.primaryGreen

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 28))
                .foregroundColor(iconColor)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.app.title2)
                    .foregroundColor(textColor)

                Text(message)
                    .font(.app.title1)
                    .foregroundColor(textColor.opacity(0.75))
            }
            
            Spacer()
            
            VStack {
                Text(timeString)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(textColor)
                Spacer()
            }
        }
        .padding(16)
        .background(backgroundColor)
        .cornerRadius(12)
    }
}

extension AlertBannerComponent {
    init(alertType: AlertType, timeString: String) {
        
        let computedIcon: String
        switch alertType.title {
        case "High Humidity": computedIcon = "humidity.fill"
        case "Low Humidity": computedIcon = "humidity"
        case "Humidity Normalized": computedIcon = "drop.fill"
        case "Lost Connection": computedIcon = "wifi.slash"
        case "Connection Back": computedIcon = "wifi"
        case "High Temperature": computedIcon = "thermometer.sun"
        case "Low Temperature": computedIcon = "thermometer.snowflake"
        case "Temperature Normalized": computedIcon = "thermometer.variable"
        default: computedIcon = "bell.fill"
        }
        
        let bg: Color
        let fg: Color
        
        switch alertType.severity.lowercased() {
        case "warning":
            bg = Color.theme.primaryYellow.opacity(0.1)
            fg = Color.theme.primaryYellow
        case "critical":
            bg = Color.theme.primaryRed.opacity(0.1)
            fg = Color.theme.primaryRed
        default: // "info" atau normal
            bg = Color.theme.primaryGreen.opacity(0.1)
            fg = Color.theme.primaryGreen
        }
        
        self.init(
            title: alertType.title,
            message: alertType.description ?? "",
            timeString: timeString,
            iconName: computedIcon,
            backgroundColor: bg,
            iconColor: fg,
            textColor: fg
        )
    }
}
