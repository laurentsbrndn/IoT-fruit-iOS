//
//  ShipmentSummaryMenuComponent.swift
//  BIKI LiveTrack
//
//  Created by Joana Mardas on 17/08/26.
//

import SwiftUI

struct ShipmentSummaryMenuComponent: View {
    let onExportCSV: () -> Void
    let onExportGraphPNG: () -> Void
    let onAdjustStartDateTime: () -> Void
    let onAdjustEndDateTime: () -> Void

    var body: some View {
        Menu {
            Button {
                onExportCSV()
            } label: {
                Label(
                    "Export Data\nAs CSV",
                    systemImage: "square.and.arrow.up"
                )
            }

            Button {
                onExportGraphPNG()
            } label: {
                Label(
                    "Export Graph\nAs PNG",
                    systemImage: "square.and.arrow.up"
                )
            }

            Divider()

            Button {
                onAdjustStartDateTime()
            } label: {
                Label(
                    "Adjust Start Date & Time",
                    systemImage: "calendar.badge.clock"
                )
            }

            Button {
                onAdjustEndDateTime()
            } label: {
                Label(
                    "Adjust End Date & Time",
                    systemImage: "calendar.badge.clock"
                )
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
                .frame(width: 44, height: 44)
                .background(Color.white)
                .clipShape(Circle())
        }
        .accessibilityLabel("Shipment options")
    }
}

#Preview {
    ZStack {
        Color.theme.tertiaryGreen
            .ignoresSafeArea()

        ShipmentSummaryMenuComponent(
            onExportCSV: {},
            onExportGraphPNG: {},
            onAdjustStartDateTime: {},
            onAdjustEndDateTime: {}
        )
    }
}
