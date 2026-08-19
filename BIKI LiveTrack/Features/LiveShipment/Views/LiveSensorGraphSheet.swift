//
//  Untitled.swift
//  BIKI LiveTrack
//
//  Created by Joana Mardas on 18/08/26.
//

import SwiftUI
import Charts

struct LiveSensorGraphSheet: View {
    @ObservedObject var viewModel: LiveShipmentViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                header

                LiveSensorChart(
                    title: "Temperature over time",
                    currentValue: viewModel.temperatureValueText,
                    unit: "°C",
                    readings: viewModel.temperatureChartReadings,
                    idealRange: viewModel.temperatureIdealRange
                )

                LiveSensorChart(
                    title: "Humidity over time",
                    currentValue: viewModel.humidityValueText,
                    unit: "%",
                    readings: viewModel.humidityChartReadings,
                    idealRange: viewModel.humidityIdealRange
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }

        .presentationDetents([.fraction(0.85)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
    }

    private var header: some View {
        HStack {
            Spacer()

            Text("Live Sensor Data")
                .font(.app.bodyBold)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .overlay(alignment: .trailing) {
            Button("Close", systemImage: "xmark") {
                dismiss()
            }
            .labelStyle(.iconOnly)
            .foregroundStyle(.secondary)
            .accessibilityLabel("Close live sensor data")
        }
        .padding(.top, 24)
    }
}

private struct LiveSensorChart: View {
    let title: String
    let currentValue: String
    let unit: String
    let readings: [LiveChartReading]
    let idealRange: ClosedRange<Double>

    @State private var selectedTimestamp: Date?

    private let idealRangeColor =
        Color.theme.secondaryGreen

    private let idealColor =
        Color.theme.primaryGreen

    private let warningColor =
        Color.theme.primaryYellow

    private let visibleDuration: TimeInterval =
        4 * 60 * 60

    private var currentValueColor: Color {
        guard let latestReading = readings.last else {
            return .secondary
        }

        return idealRange.contains(latestReading.value)
            ? idealColor
            : warningColor
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            chartHeader
            chart
        }
        .padding(20)
        .background(
            Color.white,
            in: RoundedRectangle(cornerRadius: 18)
        )
    }

    // MARK: - Header

    private var chartHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(
                alignment: .center,
                spacing: 12
            ) {
                Text(title)
                    .font(.app.bodyBold)

                Spacer()

                HStack(spacing: 8) {
                    Rectangle()
                        .fill(idealRangeColor)
                        .frame(
                            width: 32,
                            height: 14
                        )

                    Text("Ideal")
                        .font(.app.body)
                        .foregroundStyle(.secondary)
                }
            }

            Text(currentValue)
                .font(
                    .system(
                        size: 28,
                        weight: .semibold
                    )
                )
                .foregroundStyle(currentValueColor)
        }
    }

    // MARK: - Chart

    private var chart: some View {
        Chart {
            idealRangeMark
            readingMarks
            selectedReadingMark
        }
        .chartYScale(domain: yDomain)
        .chartXScale(
            domain: chartStart...chartEnd
        )
        .chartScrollableAxes(.horizontal)
        .chartXVisibleDomain(
            length: visibleDuration
        )
        .chartXSelection(
            value: $selectedTimestamp
        )
        .chartXAxis {
            AxisMarks(
                values: .stride(by: .hour)
            ) { axisValue in
                AxisGridLine(
                    stroke: StrokeStyle(
                        lineWidth: 0.5,
                        dash: [3, 3]
                    )
                )
                .foregroundStyle(
                    .secondary.opacity(0.25)
                )

                AxisTick()

                AxisValueLabel(centered: true) {
                    if let date =
                        axisValue.as(Date.self) {
                        Text(
                            clockText(for: date)
                        )
                    }
                }
                .foregroundStyle(.secondary)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) {
                AxisGridLine(
                    stroke: StrokeStyle(
                        lineWidth: 0.5,
                        dash: [3, 3]
                    )
                )
                .foregroundStyle(
                    .secondary.opacity(0.25)
                )

                AxisValueLabel()
                    .foregroundStyle(.secondary)
            }
        }
        .frame(height: 220)
    }

    // MARK: - Ideal Range

    @ChartContentBuilder
    private var idealRangeMark: some ChartContent {
        RectangleMark(
            xStart: .value(
                "Chart start",
                chartStart
            ),
            xEnd: .value(
                "Chart end",
                chartEnd
            ),
            yStart: .value(
                "Ideal minimum",
                idealRange.lowerBound
            ),
            yEnd: .value(
                "Ideal maximum",
                idealRange.upperBound
            )
        )
        .foregroundStyle(idealRangeColor)
    }

    // MARK: - Sensor Line

    @ChartContentBuilder
    private var readingMarks: some ChartContent {
        liveLineMarks
        livePointMarks
    }

    @ChartContentBuilder
    private var liveLineMarks: some ChartContent {
        ForEach(lineSegments) { segment in
            LineMark(
                x: .value("Time", segment.start.timestamp),
                y: .value("Reading", segment.start.value),
                series: .value("Segment", segment.id)
            )
            .interpolationMethod(.linear)
            .lineStyle(
                StrokeStyle(
                    lineWidth: 2.5,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
            .foregroundStyle(lineColor(for: segment))

            LineMark(
                x: .value("Time", segment.end.timestamp),
                y: .value("Reading", segment.end.value),
                series: .value("Segment", segment.id)
            )
            .interpolationMethod(.linear)
            .lineStyle(
                StrokeStyle(
                    lineWidth: 2.5,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
            .foregroundStyle(lineColor(for: segment))
        }
    }

    @ChartContentBuilder
    private var livePointMarks: some ChartContent {
        ForEach(readings) { reading in
            PointMark(
                x: .value("Time", reading.timestamp),
                y: .value("Reading", reading.value)
            )
            .symbolSize(24)
            .foregroundStyle(pointColor(for: reading))
        }
    }

    private struct LiveLineSegment: Identifiable {
        let id: String
        let start: LiveChartReading
        let end: LiveChartReading
        let isIdeal: Bool
    }

    private var lineSegments: [LiveLineSegment] {
        zip(readings, readings.dropFirst()).map {
            startReading,
            endReading in

            let startIsIdeal =
                idealRange.contains(startReading.value)

            let endIsIdeal =
                idealRange.contains(endReading.value)

            return LiveLineSegment(
                id:
                    "\(startReading.id.uuidString)-\(endReading.id.uuidString)",
                start: startReading,
                end: endReading,
                isIdeal: startIsIdeal && endIsIdeal
            )
        }
    }

    private func lineColor(
        for segment: LiveLineSegment
    ) -> Color {
        segment.isIdeal
            ? idealColor
            : warningColor
    }

    private func pointColor(
        for reading: LiveChartReading
    ) -> Color {
        idealRange.contains(reading.value)
            ? idealColor
            : warningColor
    }
    // MARK: - Selected Point

    @ChartContentBuilder
    private var selectedReadingMark: some ChartContent {
        if let selectedReading {
            RuleMark(
                x: .value(
                    "Selected time",
                    selectedReading.timestamp
                )
            )
            .foregroundStyle(
                Color.theme.primaryGreen.opacity(0.45)
            )
            .lineStyle(
                StrokeStyle(
                    lineWidth: 1,
                    dash: [4, 4]
                )
            )
            .annotation(position: .top) {
                selectedPointPopup(
                    for: selectedReading
                )
            }
        }
    }

    private var selectedReading: LiveChartReading? {
        guard let selectedTimestamp else {
            return nil
        }

        return readings.min {
            abs(
                $0.timestamp.timeIntervalSince(
                    selectedTimestamp
                )
            )
            <
            abs(
                $1.timestamp.timeIntervalSince(
                    selectedTimestamp
                )
            )
        }
    }

    private func selectedPointPopup(
        for reading: LiveChartReading
    ) -> some View {
        VStack(spacing: 3) {
            Text(clockText(for: reading.timestamp))
                .font(
                    .caption.weight(.semibold)
                )

            Text(valueText(for: reading))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(8)
        .background(
            Color.white,
            in: RoundedRectangle(cornerRadius: 8)
        )
        .shadow(
            color: .black.opacity(0.12),
            radius: 4,
            y: 2
        )
    }

    // MARK: - Chart Ranges

    private var chartStart: Date {
        let firstTimestamp =
            readings.first?.timestamp ?? Date()

        return Calendar.current.dateInterval(
            of: .hour,
            for: firstTimestamp
        )?.start
        ?? firstTimestamp
    }

    private var chartEnd: Date {
        let minimumEnd =
            Calendar.current.date(
                byAdding: .hour,
                value: 4,
                to: chartStart
            )
            ?? chartStart.addingTimeInterval(
                visibleDuration
            )

        guard let lastTimestamp =
                readings.last?.timestamp
        else {
            return minimumEnd
        }

        let endOfLastHour =
            Calendar.current.dateInterval(
                of: .hour,
                for: lastTimestamp
            )?.end
            ?? lastTimestamp

        return max(
            endOfLastHour,
            minimumEnd
        )
    }

    private var yDomain: ClosedRange<Double> {
        let values =
            readings.map(\.value)
            + [
                idealRange.lowerBound,
                idealRange.upperBound
            ]

        let minimum =
            values.min()
            ?? idealRange.lowerBound

        let maximum =
            values.max()
            ?? idealRange.upperBound

        let padding = max(
            (maximum - minimum) * 0.35,
            unit == "%" ? 5 : 2
        )

        return
            (minimum - padding)
            ...
            (maximum + padding)
    }

    // MARK: - Formatting

    private func clockText(
        for date: Date
    ) -> String {
        let components =
            Calendar.current.dateComponents(
                [.hour, .minute],
                from: date
            )

        return String(
            format: "%02d.%02d",
            components.hour ?? 0,
            components.minute ?? 0
        )
    }

    private func valueText(
        for reading: LiveChartReading
    ) -> String {
        String(
            format: "%.1f",
            reading.value
        ) + unit
    }
}
