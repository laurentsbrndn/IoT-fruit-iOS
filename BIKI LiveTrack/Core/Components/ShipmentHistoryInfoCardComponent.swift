//
//  ShipmentHistoryInfoCardComponent.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 11/08/26.
//

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
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .center, spacing: 12) {
                            Text(shipmentID)
                                .font(.app.heading2)
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            
                            Spacer(minLength: 12)
                        }
                        
                        HStack(alignment :.top, spacing: 4) {
                            Image(systemName: "location")
                                .foregroundStyle(.primary)
                            
                            LocationLabelComponent(
                                latitude: latitude,
                                longitude: longitude
                            )
                        }
                        // KEMBALIKAN KE SEMULA: Hapus maxHeight di sini
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Spacer(minLength: 12)

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(statusText)
                            .font(.app.captionBold)
                            .foregroundStyle(Color.theme.primaryGreen)

                        Text(statusDate)
                            .font(.app.captionBold)
                            .foregroundStyle(.secondary)
                        
                    }
                }

                // TAMBAHAN: Spacer ini akan mendorong Divider dan info Driver
                // ke bagian paling bawah card jika card memanjang karena mengikuti card lain.
                Spacer(minLength: 0)

                Divider()
                    .overlay(Color(uiColor: .separator))

                HStack(spacing: 0) {
                    ShipmentHistoryInfoItem(
                        systemImage: "person",
                        text: driverName
                    )

                    Spacer(minLength: 16)

                    Rectangle()
                        .fill(Color(uiColor: .separator))
                        .frame(width: 1, height: 28)

                    Spacer(minLength: 16)

                    ShipmentHistoryInfoItem(
                        systemImage: "phone",
                        text: driverContact
                    )
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        // PINDAHKAN KE SINI: maxHeight: .infinity diletakkan di container terluar
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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
