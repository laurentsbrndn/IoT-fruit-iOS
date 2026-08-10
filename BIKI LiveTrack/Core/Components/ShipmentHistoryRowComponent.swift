//
//  ShipmentHistoryRowComponent.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 10/08/26.
//

import SwiftUI

struct ShipmentHistoryRowComponent: View {
    var shipmentID: String
    var route: String
    var shipmentDate: String
    var shipmentTime: String
    var arrivalDate: String
    var arrivalTime: String
    var deviceName: String
    var driverName: String
    var driverContact: String
    var truckPlate: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(shipmentID)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color.theme.primary)
                
                Text(route)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color.theme.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(shipmentDate)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color.theme.textPrimary)
                
                Text(shipmentTime)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color.theme.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(arrivalDate)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color.theme.textPrimary)
                
                Text(arrivalTime)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color.theme.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(deviceName)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color.theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(driverName)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color.theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(driverContact)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color.theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(truckPlate)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color.theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color.theme.textSecondary)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(Color.white)
        .clipShape(
            RoundedRectangle(cornerRadius: 25)
        )
    }
}

#Preview {
    ZStack {
        Color.theme.background.ignoresSafeArea()
        ScrollView(.horizontal, showsIndicators: false) {
            ShipmentHistoryRowComponent(
                shipmentID: "#BIKI11750",
                route: "SMG → BSD",
                shipmentDate: "6 Aug 2026",
                shipmentTime: "07:00",
                arrivalDate: "7 Aug 2026",
                arrivalTime: "15:00",
                deviceName: "IoT_01",
                driverName: "Septa Bayu",
                driverContact: "0878492361",
                truckPlate: "DK 8959 JKY"
            )
            .frame(minWidth: 1000)
            .padding()
        }
    }
}
