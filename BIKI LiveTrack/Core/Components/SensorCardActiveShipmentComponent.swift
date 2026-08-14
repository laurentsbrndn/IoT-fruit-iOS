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
    var status: DeviceStatus
    var progress: Double
    
//
    private var isOffline: Bool {
        status == .offline
    }
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.theme.textSecondary)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.theme.textSecondary)
                }
                
                Text(value)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(Color.theme.textPrimary)
                
  
                StatusBadgeComponent(status: status)
            }
            
            Spacer()
            
            VerticalSensorGauge(
                progress: isOffline ? 0.65 : progress,
                color: isOffline ? Color.theme.grey : status.foregroundColor,
                isOffline: isOffline
            )
        }
        .padding(24)
        .frame(width: 334, height: 181)
        .background(isOffline ? Color.theme.grey : Color.white)
        .cornerRadius(20)
        .shadow(color: isOffline ? .clear : .black.opacity(0.08), radius: 4, y: 4)
    }
    
    // Sensor slider kanan
    struct VerticalSensorGauge: View {
        var progress: Double
        var color: Color
        var isOffline: Bool = false
        
        var body: some View {
            GeometryReader { geo in
                let fillHeight = geo.size.height * CGFloat(max(0.05, min(progress, 1.0)))
                
                ZStack(alignment: .bottom) {
                    Capsule()
                        .fill(isOffline ? Color.white.opacity(0.6) : Color.theme.tertiaryGreen)
                    
                    Capsule()
                        .fill(color)
                        .frame(height: fillHeight)
                        .padding(isOffline ? 3 : 0)
                    
//buat buletan indikator
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

#Preview (traits: .landscapeRight) {
    ZStack {
        Color.theme.tertiaryGreen.ignoresSafeArea()
        
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                // 1. Status Warning
                SensorCardActiveShipmentComponent(
                    title: "Humidity",
                    value: "80%",
                    status: .warning,
                    progress: 0.85
                )
                
                // 2. Status Ideal
                SensorCardActiveShipmentComponent(
                    title: "Temperature",
                    value: "10°C",
                    status: .ideal,
                    progress: 0.5
                )
                
                // 3. Status Offline
                SensorCardActiveShipmentComponent(
                    title: "Humidity",
                    value: "0%",
                    status: .offline,
                    progress: 0.0
                )
            }
            .padding()
        }
    }
}
