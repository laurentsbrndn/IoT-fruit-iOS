//
//  SensorCardActiveShipment.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 10/08/26.
//

import SwiftUI

struct SensorCardActiveShipmentComponent: View {
    var title: String
    var value: String
    var statusIcon: String
    var statusText: String
    var statusColor: Color
    var progress: Double
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.theme.textSecondary)
           
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.theme.textSecondary)
                }
                
                Text(value)
                    .font(.system(size: 42, weight: .semibold))
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
                
                Spacer(minLength: 0)
            }
            
            Spacer()
            
            VerticalSensorGauge(progress: progress, color: statusColor)
        }
        .padding(20)
        .frame(height: 170)
        .background(Color.white)
        .cornerRadius(24)
    }
    
    struct VerticalSensorGauge: View {
        var progress: Double
        var color: Color
        
        var body: some View {
            GeometryReader { geo in
                let fillHeight = geo.size.height * CGFloat(max(0.15, min(progress, 1.0)))
                
                ZStack(alignment: .bottom) {
                    Capsule()
                        .fill(Color.theme.tertiaryGreen)
                    
                    VStack {
                        Capsule().fill(Color.gray.opacity(0.3)).frame(width: 8, height: 2).padding(.top, 6)
                        Spacer()
                        Capsule().fill(Color.gray.opacity(0.3)).frame(width: 8, height: 2).padding(.bottom, 6)
                    }
                    
                    Capsule()
                        .fill(color)
                        .frame(height: fillHeight)
                    
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 3)
                        .background(Circle().fill(color))
                        .frame(width: geo.size.width - 6, height: geo.size.width - 6)
                        .padding(.bottom, fillHeight - geo.size.width + 3)
                }
            }
            .frame(width: 22)
        }
    }
}

#Preview {
    ZStack {
        Color.theme.tertiaryGreen.ignoresSafeArea()
        
        HStack(spacing: 16) {
            SensorCardActiveShipmentComponent(
                title: "Temperature",
                value: "10°C",
                statusIcon: "checkmark.circle.fill",
                statusText: "Ideal",
                statusColor: Color.theme.primaryGreen,
                progress: 0.5
            )
            
            SensorCardActiveShipmentComponent(
                title: "Humidity",
                value: "50%",
                statusIcon: "exclamationmark.triangle.fill",
                statusText: "Warning",
                statusColor: Color.theme.primaryYellow,
                progress: 0.85
            )
        }
        .padding()
    }
}
