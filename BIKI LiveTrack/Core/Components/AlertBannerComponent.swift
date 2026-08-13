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
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 28))
                .foregroundColor(iconColor)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(textColor)

                Text(message)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(textColor.opacity(0.75))
            }

            Spacer()

            Text(timeString)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(textColor.opacity(0.75))
                .padding(.top, 2)
        }
        .padding(16)
        .background(backgroundColor)
        .cornerRadius(12)
    }
}

extension AlertBannerComponent {
    init(alertType: AlertType, timeString: String) {
        self.init(
            title: alertType.title,
            message: alertType.description ?? "",
            timeString: timeString,
            iconName: alertType.iconName
        )
    }
}

#Preview {
    ZStack {
        Color.theme.tertiaryGreen.ignoresSafeArea()

        ScrollView {
            VStack(spacing: 12) {
                AlertBannerComponent(
                    title: "High Humidity",
                    message: "Humidity is above the ideal range",
                    timeString: "10 minutes ago",
                    iconName: "humidity.fill"
                )
                AlertBannerComponent(
                    title: "Low Humidity",
                    message: "Humidity has dropped below the ideal range",
                    timeString: "10 minutes ago",
                    iconName: "humidity"
                )
                AlertBannerComponent(
                    title: "Humidity Normalized",
                    message: "Humidity is back within the ideal range",
                    timeString: "10 minutes ago",
                    iconName: "drop.fill"
                )
                AlertBannerComponent(
                    title: "Lost Connection",
                    message: "Sensor stopped sending data",
                    timeString: "1 hour ago",
                    iconName: "wifi.slash"
                )
                AlertBannerComponent(
                    title: "Connection Back",
                    message: "Sensor is back online and reporting normally",
                    timeString: "1 hour ago",
                    iconName: "wifi"
                )
                AlertBannerComponent(
                    title: "High Temperature",
                    message: "Temperature is above the ideal range",
                    timeString: "5 hour ago",
                    iconName: "thermometer.sun"
                )
                AlertBannerComponent(
                    title: "Low Temperature",
                    message: "Temperature has dropped below the ideal range",
                    timeString: "4 hour ago",
                    iconName: "thermometer.snowflake"
                )
                AlertBannerComponent(
                    title: "Temperature Normalized",
                    message: "Temperature is back within the ideal range",
                    timeString: "4 hour ago",
                    iconName: "thermometer.variable"
                )
            }
            .padding()
        }
    }
}
