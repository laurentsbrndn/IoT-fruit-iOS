//
//  ShipmentInfoCardComponent.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 10/08/26.
//

import SwiftUI
import CoreLocation

struct ShipmentLiveInfoCardComponent: View {
    var shipmentID: String
    var status: DeviceStatus
    var latitude: Double
    var longitude: Double
    var driverName: String
    var driverContact: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .center, spacing: 12) {
                    Text(shipmentID)
                        .font(.app.heading2)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    Spacer(minLength: 12)
                    
                    StatusBadgeComponent(
                        status: status
                    )
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "location")
                        .foregroundStyle(.secondary)
                    
                    LocationLabelComponent(
                        latitude: latitude,
                        longitude: longitude
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Divider()
                .overlay(Color(uiColor: .separator))

            HStack(spacing: 0) {
                ShipmentInfoItem(
                    systemImage: "person",
                    text: driverName
                )

                Spacer(minLength: 16)

                Rectangle()
                    .fill(Color(uiColor: .separator))
                    .frame(width: 1, height: 28)

                Spacer(minLength: 16)

                ShipmentInfoItem(
                    systemImage: "phone",
                    text: driverContact
                )
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .systemBackground))
        .clipShape(.rect(cornerRadius: 24))
        .accessibilityElement(children: .contain)
    }
}

private struct ShipmentInfoItem: View {
    let systemImage: String
    let text: String
    
    var body: some View {
        Label {
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        } icon: {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(.secondary)
                .symbolRenderingMode(.hierarchical)
        }
        .labelStyle(.titleAndIcon)
    }
}

#Preview {
    ZStack {
        Color(uiColor: .secondarySystemBackground)
            .ignoresSafeArea()

        ShipmentLiveInfoCardComponent(
            shipmentID: "#BIKI11750",
            status: .warning,
            latitude: -6.1754,
            longitude: 106.8272,
            driverName: "Bayu Sapta Haji",
            driverContact: "0818 6789 7689"
        )
        .padding(.horizontal)
    }
}
