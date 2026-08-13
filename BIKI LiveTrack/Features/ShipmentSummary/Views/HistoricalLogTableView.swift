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
    @ObservedObject var viewModel: ShipmentSummaryViewModel

    var body: some View {
        VStack(spacing: 0) {
            tableHeader

            ForEach(Array(viewModel.sensorLogs.enumerated()), id: \.element.id) { index, log in
                tableRow(log, background: index.isMultiple(of: 2) ? Color.white : Color.theme.lightGreen)
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
        .background(Color.theme.tertiaryGreen)
    }

    private func tableRow(_ log: SensorLog, background: Color) -> some View {
        HStack(spacing: 16) {
            tableCell(log.timestamps?.toReadableString() ?? "—", alignment: .leading)
            tableCell(viewModel.temperatureText(log.temperature), alignment: .leading)
            tableCell(viewModel.humidityText(log.humidity), alignment: .leading)
            tableCell(viewModel.tableLocationText(for: log), alignment: .leading)
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
}
