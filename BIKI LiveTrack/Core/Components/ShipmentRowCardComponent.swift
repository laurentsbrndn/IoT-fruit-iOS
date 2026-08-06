//
//  ShipmentRowCardComponent.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 06/08/26.
//

import SwiftUI

struct ShipmentRowCard: View {
    let shipment: Shipment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                StatusBadgeView(status: "Active")
                Spacer()
                Text(shipment.startDate.toReadableString())
                    .font(.app.caption)
                    .foregroundColor(Color.theme.textSecondary)
            }
            
            HStack(spacing: 16) {
                Image(systemName: "box.truck.fill")
                    .font(.system(size: 32))
                    .foregroundColor(Color.theme.primary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(shipment.truckPlateNumber)
                        .font(.app.heading2)
                        .foregroundColor(Color.theme.textPrimary)
                    
                    Text("Device ID: \(shipment.deviceID.uuidString.prefix(8))...")
                        .font(.app.caption)
                        .foregroundColor(Color.theme.textSecondary)
                }
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.theme.textSecondary)
            }
        }
        .padding()
        .background(Color.theme.surface)
        .cardStyle()
    }
}
