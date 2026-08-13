//
//  Untitled.swift
//  BIKI LiveTrack
//
//  Created by Joana Mardas on 13/08/26.
//
//
//  HistoricalLogTableView.swift
//  BIKI LiveTrack
//

import SwiftUI

struct HistoricalLogTableView: View {
    let sensorLogs: [SensorLog]

    var body: some View {
        VStack(spacing: 0) {
            tableHeader

            ForEach(Array(sensorLogs.enumerated()), id: \.element.id) { index, log in
                tableRow(log, background: index.isMultiple(of: 2) ? Color.theme.TableRow1 : Color.theme.TableRow2)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var tableHeader: some View {
        HStack(spacing: 16) {
            tableCell("Time", alignment: .leading)
            tableCell("Temperature", alignment: .leading)
            tableCell("Humidity", alignment: .leading)
            tableCell("Location", alignment: .leading)
        }
        .font(.app.bodyBold)
        .foregroundColor(.white)
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .background(Color.theme.primary)
    }

    private func tableRow(_ log: SensorLog, background: Color) -> some View {
        HStack(spacing: 16) {
            tableCell(log.timestamps?.toReadableString() ?? "—", alignment: .leading)
            tableCell(formatted(log.temperature, suffix: "°C"), alignment: .leading)
            tableCell(formatted(log.humidity, suffix: "%"), alignment: .leading)
            tableCell(locationText(for: log), alignment: .leading)
        }
        .font(.app.body)
        .foregroundColor(Color.theme.textPrimary)
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(background)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color(uiColor: .separator)).frame(height: 1)
        }
    }

    private func tableCell(_ text: String, alignment: Alignment) -> some View {
        Text(text)
            .frame(maxWidth: .infinity, alignment: alignment)
            .lineLimit(2)
    }

    private func formatted(_ value: Double?, suffix: String) -> String {
        guard let value else { return "—" }
        return value.rounded() == value ? "\(Int(value))\(suffix)" : String(format: "%.1f%@", value, suffix)
    }

    private func locationText(for log: SensorLog) -> String {
        guard let latitude = log.averageLatitude, let longitude = log.averageLongitude else { return "—" }
        return String(format: "%.4f, %.4f", latitude, longitude)
    }
}

#Preview("Historical Log Table", traits: .landscapeLeft) {
    HistoricalLogTableView(sensorLogs: ShipmentSummaryPreviewData.sensorLogs)
        .padding()
        .background(Color.theme.background)
        .frame(width: 1_100, height: 460)
}
