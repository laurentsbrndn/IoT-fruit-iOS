//
//  HistoricalLogGraphView.swift
//  BIKI LiveTrack
//

import SwiftUI
import Charts

struct HistoricalLogGraphView: View {
    let sensorLogs: [SensorLog]

    // For a recommended range, the chart's baseline is its midpoint.
    // Bars above/below it clearly show movement away from the target.
    private let temperatureTarget = 8.0
    private let humidityTarget = 87.5

    var body: some View {
        VStack(spacing: 20) {
            HealthStyleBarChart(
                title: "Temperature over time",
                unit: "°C",
                targetValue: temperatureTarget,
                idealRange: 2...14,
                readings: temperatureReadings,
                tint: Color.theme.primary
            )

            HealthStyleBarChart(
                title: "Humidity over time",
                unit: "%",
                targetValue: humidityTarget,
                idealRange: 85...90,
                readings: humidityReadings,
                tint: Color.theme.Update
            )
        }
    }

    private var temperatureReadings: [HistoricalMetricReading] {
        sensorLogs.compactMap { log in
            guard let timestamp = log.timestamps, let value = log.temperature else { return nil }
            return HistoricalMetricReading(id: log.id, timestamp: timestamp, value: value)
        }
    }

    private var humidityReadings: [HistoricalMetricReading] {
        sensorLogs.compactMap { log in
            guard let timestamp = log.timestamps, let value = log.humidity else { return nil }
            return HistoricalMetricReading(id: log.id, timestamp: timestamp, value: value)
        }
    }
}

private struct HistoricalMetricReading: Identifiable {
    let id: UUID
    let timestamp: Date
    let value: Double
}

private struct HealthStyleBarChart: View {
    let title: String
    let unit: String
    let targetValue: Double
    let idealRange: ClosedRange<Double>
    let readings: [HistoricalMetricReading]
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.app.title)
                .foregroundColor(Color.theme.textPrimary)

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(formattedAverage)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(tint)
                Text(unit)
                    .font(.app.bodyBold)
                    .foregroundColor(tint)
            }

            Chart {
                // A quiet coloured band is the ideal zone. It stays inside the
                // chart's plot area, unlike an annotation that can be clipped.
                RectangleMark(
                    yStart: .value("Ideal minimum", idealRange.lowerBound),
                    yEnd: .value("Ideal maximum", idealRange.upperBound)
                )
                .foregroundStyle(tint.opacity(0.10))

                RuleMark(y: .value("Ideal minimum", idealRange.lowerBound))
                    .foregroundStyle(tint.opacity(0.45))
                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 4]))

                RuleMark(y: .value("Ideal maximum", idealRange.upperBound))
                    .foregroundStyle(tint.opacity(0.45))
                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 4]))

                ForEach(readings) { reading in
                    // Starting every bar at the target baseline lets it visibly
                    // rise above or fall below the target, like Apple Health.
                    BarMark(
                        x: .value("Time", reading.timestamp),
                        yStart: .value("Target", targetValue),
                        yEnd: .value("Reading", reading.value),
                        width: .fixed(9)
                    )
                    .foregroundStyle(idealRange.contains(reading.value) ? tint : Color.theme.warning)
                    .cornerRadius(5)
                }
            }
            .chartYScale(domain: yDomain)
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 3)) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0))
                    AxisTick(stroke: StrokeStyle(lineWidth: 0))
                    AxisValueLabel(format: .dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits))
                        .font(.caption)
                        .foregroundStyle(Color.theme.textSecondary)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [3, 4]))
                        .foregroundStyle(Color.gray.opacity(0.25))
                    AxisValueLabel {
                        if let number = value.as(Double.self) {
                            Text(formatted(number))
                                .font(.caption)
                                .foregroundStyle(Color.theme.textSecondary)
                        }
                    }
                }
            }
            .frame(height: 210)
        }
        .padding(24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .accessibilityLabel("\(title). Shaded area is the ideal range from \(formatted(idealRange.lowerBound)) to \(formatted(idealRange.upperBound))\(unit).")
    }

    private var formattedAverage: String {
        guard !readings.isEmpty else { return "—" }
        return formatted(readings.map(\.value).reduce(0, +) / Double(readings.count))
    }

    private var yDomain: ClosedRange<Double> {
        let values = readings.map(\.value) + [idealRange.lowerBound, idealRange.upperBound, targetValue]
        let minimum = values.min() ?? targetValue
        let maximum = values.max() ?? targetValue
        let padding = max((maximum - minimum) * 0.35, unit == "%" ? 5 : 2)
        return (minimum - padding)...(maximum + padding)
    }

    private func formatted(_ value: Double) -> String {
        value.rounded() == value ? String(Int(value)) : String(format: "%.1f", value)
    }
}

#Preview("Historical Log Graph", traits: .landscapeLeft) {
    ScrollView {
        HistoricalLogGraphView(sensorLogs: ShipmentSummaryPreviewData.sensorLogs)
            .padding()
    }
    .background(Color.theme.background)
    .frame(width: 1_100, height: 460)
}
