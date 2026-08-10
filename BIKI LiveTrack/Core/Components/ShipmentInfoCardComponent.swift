//
//  ShipmentInfoCardComponent.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 10/08/26.
//

import SwiftUI
import CoreLocation

struct ShipmentInfoCardComponent: View {
    var shipmentID: String
    var statusIcon: String
    var statusText: String
    var statusColor: Color
    var latitude: Double
    var longitude: Double
    var driverName: String
    var driverContact: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center) {
                Text(shipmentID)
                    .font(.system(size: 32, weight: .regular))
                    .foregroundColor(Color.theme.textPrimary)
                
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: statusIcon)
                        .font(.system(size: 12, weight: .bold))
                    Text(statusText)
                        .font(.system(size: 13, weight: .semibold))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(statusColor)
                .foregroundColor(.white)
                .clipShape(Capsule())
            }
            
            LocationLabelComponent(latitude: latitude, longitude: longitude)
                .frame(height: 22, alignment: .leading)
            
            Divider()
                .background(Color.gray.opacity(0.3))
                .padding(.vertical, 2)
            
            HStack {
                Text(driverName)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color.theme.textPrimary)
                
                Spacer()
                
                Text(driverContact)
                    .font(.system(size: 16, weight: .regular))
                    .monospacedDigit()
                    .foregroundColor(Color.theme.textPrimary)
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(24)
    }
}

#Preview {
    ZStack {
        Color.theme.background.ignoresSafeArea()
        
        VStack {
            ShipmentInfoCardComponent(
                shipmentID: "#BIKI11750",
                statusIcon: "exclamationmark.triangle.fill",
                statusText: "Warning",
                statusColor: Color.theme.warning,
                latitude: -6.1754,
                longitude: 106.8272,
                driverName: "Bayu Sapta Haji",
                driverContact: "0878 xxx xxx"
            )
            .padding()
        }
    }
}
