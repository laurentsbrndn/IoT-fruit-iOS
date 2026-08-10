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
    var statusIcon: String
    var statusText: String
    var statusColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color.theme.textSecondary)
            
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Average")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.theme.textSecondary)
                    
                    Text(averageValue)
                        .font(.system(size: 42, weight: .regular))
                        .foregroundColor(Color.theme.textPrimary)
                    
                    HStack(spacing: 6) {
                        Image(systemName: statusIcon)
                            .font(.system(size: 12, weight: .bold))
                        Text(statusText)
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(statusColor)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .padding(.top, 4)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Min")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.theme.textSecondary)
                        
                        Text(minValue)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.theme.textPrimary)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Max")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.theme.textSecondary)
                        
                        Text(maxValue)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.theme.textPrimary)
                    }
                }
                .padding(.trailing, 8)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(24)
    }
}

#Preview {
    ZStack {
        Color.theme.background.ignoresSafeArea()
        
        HStack(spacing: 16) {
            SensorCardShipmentHistoryComponent(
                title: "Temperature",
                averageValue: "10°C",
                minValue: "8°C",
                maxValue: "14°C",
                statusIcon: "checkmark.circle.fill",
                statusText: "Ideal",
                statusColor: Color.theme.primary
            )
            
            SensorCardShipmentHistoryComponent(
                title: "Humidity",
                averageValue: "70%",
                minValue: "68%",
                maxValue: "75%",
                statusIcon: "checkmark.circle.fill",
                statusText: "Ideal",
                statusColor: Color.theme.primary
            )
        }
        .padding()
    }
}
