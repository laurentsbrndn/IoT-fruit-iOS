//
//  ShipmentHistoryInfoCardComponent.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 11/08/26.
//

import SwiftUI
import CoreLocation

struct ShipmentHistoryInfoCardComponent: View {
    var shipmentID: String
    var statusText: String
    var statusDate: String
    var latitude: Double
    var longitude: Double
    var driverName: String
    var driverContact: String

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(shipmentID)
                            .font(.title2.weight(.regular))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        LocationLabelComponent(
                            latitude: latitude,
                            longitude: longitude
                        )
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Spacer(minLength: 12)

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(statusText)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.green)

                        Text(statusDate)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }


                Divider()
                    .overlay(Color(uiColor: .separator))

                HStack(spacing: 0) {
                    ShipmentHistoryInfoItem(
                        systemImage: "person.circle.fill",
                        text: driverName
                    )

                    Spacer(minLength: 16)

                    Rectangle()
                        .fill(Color(uiColor: .separator))
                        .frame(width: 1, height: 24)

                    Spacer(minLength: 16)

                    ShipmentHistoryInfoItem(
                        systemImage: "phone",
                        text: driverContact
                    )
                }
            }


            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
                .padding(.leading, 16)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .systemBackground))
        .clipShape(.rect(cornerRadius: 20))
        .contentShape(.rect(cornerRadius: 20))
        .accessibilityElement(children: .contain)
    }
}


private struct ShipmentHistoryInfoItem: View {
    let systemImage: String
    let text: String

    var body: some View {
        Label {
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
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

        ShipmentHistoryInfoCardComponent(
            shipmentID: "#BIKI11750",
            statusText: "Delivered",
            statusDate: "Today, 16:47",
            latitude: -6.1754,
            longitude: 106.8272,
            driverName: "Bayu Sapta Haji",
            driverContact: "0818 6789 7689"
        )
        .padding(.horizontal)
    }
}
