//
//  SensorCardShipmentHistory.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 10/08/26.
//

import SwiftUI

struct SensorCardShipmentHistoryComponent: View {
    var title: String
    var averageValue: String
    var minValue: String
    var maxValue: String
    var status: DeviceStatus
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .tracking(-0.45)
                .foregroundColor(Color.theme.textPrimary)
            
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Average")
                        .font(.system(size: 15, weight: .semibold))
                        .tracking(-0.23)
                        .foregroundColor(Color.theme.textSecondary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(averageValue)
                            .font(.system(size: 45, weight: .bold))
                            .tracking(0.4)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            .foregroundColor(Color.theme.textPrimary)

                        StatusBadgeComponent(status: status)
                    }
                }
                .frame(width: 155, alignment: .leading)
                
                Spacer(minLength: 16)
                
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Min")
                            .font(.system(size: 15, weight: .semibold))
                            .tracking(-0.23)
                            .foregroundColor(Color.theme.textSecondary)
                        
                        Text(minValue)
                            .font(.system(size: 17, weight: .semibold))
                            .tracking(-0.43)
                            .foregroundColor(Color.theme.textPrimary)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Max")
                            .font(.system(size: 15, weight: .semibold))
                            .tracking(-0.23)
                            .foregroundColor(Color.theme.textSecondary)
                        
                        Text(maxValue)
                            .font(.system(size: 17, weight: .semibold))
                            .tracking(-0.43)
                            .foregroundColor(Color.theme.textPrimary)
                    }
                }
                .frame(width: 60, alignment: .leading)
            }
        }
        .padding(24)
        .frame(width: 300, height: 209)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, y: 4)
    }
}

#Preview {
    ZStack {
        Color.theme.tertiaryGreen.ignoresSafeArea()
        
        HStack(spacing: 16) {
            SensorCardShipmentHistoryComponent(
                title: "Temperature",
                averageValue: "10°C",
                minValue: "8°C",
                maxValue: "14°C",
                status: .ideal
            )
            
            SensorCardShipmentHistoryComponent(
                title: "Humidity",
                averageValue: "80%",
                minValue: "75%",
                maxValue: "85%",
                status: .warning
            )
        }
        .padding()
    }
}
