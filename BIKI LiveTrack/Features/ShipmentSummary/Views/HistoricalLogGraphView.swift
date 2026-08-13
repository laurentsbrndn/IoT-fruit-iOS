//
//  HistoricalLogGraphView.swift
//  BIKI LiveTrack
//

import SwiftUI
import Charts

struct HistoricalLogGraphView: View {
    @ObservedObject var viewModel: ShipmentSummaryViewModel

    var body: some View {
        VStack(spacing: 20) {
            HealthStyleBarChart(
                title: "Temperature over time",
                unit: "°C",
                targetValue: viewModel.temperatureTarget,
                idealRange: viewModel.temperatureIdealRange,
                readings: viewModel.temperatureReadings,
                tint: Color.theme.primaryGreen
            )

            HealthStyleBarChart(
                title: "Humidity over time",
                unit: "%",
                targetValue: viewModel.humidityTarget,
                idealRange: viewModel.humidityIdealRange,
                readings: viewModel.humidityReadings,
                tint: Color.theme.primaryGreen
            )
        }
    }
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
                .font(.app.title1)
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
                RectangleMark(
                    yStart: .value("Ideal minimum", idealRange.lowerBound),
                    yEnd: .value("Ideal maximum", idealRange.upperBound)
                )
                .foregroundStyle(tint.opacity(0.10))

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
                    .font(.app.title1)
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
                        // The middle line is the target/ideal value; the shaded
                        // region shows the complete acceptable range.
                        RectangleMark(
                            yStart: .value("Ideal minimum", idealRange.lowerBound),
                            yEnd: .value("Ideal maximum", idealRange.upperBound)
                        )
                        .foregroundStyle(tint.opacity(0.10))

                    RuleMark(y: .value("Ideal minimum", idealRange.lowerBound))
                            .foregroundStyle(tint.opacity(0.35))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))

                ForEach(readings) { reading in
                    if idealRange.contains(reading.value) {
                        BarMark(
                            x: .value("Time", reading.timestamp),
                            y: .value(title, reading.value)
                        )
                        .foregroundStyle(tint)
                        .interpolationMethod(.linear)

                        PointMark(
                            x: .value("Time", reading.timestamp),
                            y: .value(title, reading.value)
                        )
                        .foregroundStyle(tint)
                        .symbolSize(42)
                    }
                }
                // Native Swift Charts scrolling, not a ScrollView wrapped around a chart.
                .chartScrollableAxes(.horizontal)
                .chartXVisibleDomain(length: 6 * 3_600)
                .chartYScale(domain: yDomain)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .hour, count: 1)) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0))
                        AxisTick(stroke: StrokeStyle(lineWidth: 0))
                        AxisValueLabel(format: .dateTime.hour(.twoDigits(amPM: .omitted)))
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
}
