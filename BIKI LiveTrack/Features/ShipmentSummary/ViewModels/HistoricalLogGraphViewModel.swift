//
//  HistoricalLogGraphViewModel.swift
//  BIKI LiveTrack
//
//  Created by Joana Mardas on 16/08/26.
//

import Foundation
import Combine

struct HistoricalLogGraphViewModel {
    let temperature: Metric
    let humidity: Metric

    @MainActor
    init(summaryViewModel: ShipmentSummaryViewModel) {
        temperature = Metric(
            title: "Temperature over time",
            unit: "°C",
            averageText: summaryViewModel.temperatureText(
                summaryViewModel.averageTemperature
            ),
            averageValue: summaryViewModel.averageTemperature,
            targetValue: summaryViewModel.temperatureTarget,
            idealRange: summaryViewModel.temperatureIdealRange,
            readings: summaryViewModel.temperatureReadings,
            fallbackDate: summaryViewModel.shipment.startDate
        )

        humidity = Metric(
            title: "Humidity over time",
            unit: "%",
            averageText: summaryViewModel.humidityText(
                summaryViewModel.averageHumidity
            ),
            averageValue: summaryViewModel.averageHumidity,
            targetValue: summaryViewModel.humidityTarget,
            idealRange: summaryViewModel.humidityIdealRange,
            readings: summaryViewModel.humidityReadings,
            fallbackDate: summaryViewModel.shipment.startDate
        )
    }
}

// MARK: - One Graph

extension HistoricalLogGraphViewModel {
    struct LineSegment: Identifiable {
        let id: String
        let start: HistoricalMetricReading
        let end: HistoricalMetricReading
        let isIdeal: Bool
    }

    
    struct Metric {
        let title: String
        let unit: String
        let averageText: String
        let idealRange: ClosedRange<Double>

        /// True when the average value is inside the ideal range.
        let averageIsIdeal: Bool

        /// Separate line segments allow Swift Charts to give
        /// each section of the line a different color.
        let lineSegments: [LineSegment]

        // These are real database readings reduced to one point
        // for every 10-minute interval.
        let tenMinuteReadings: [HistoricalMetricReading]

        let chartStart: Date
        let chartEnd: Date
        let yDomain: ClosedRange<Double>

        // The user can see four hours before scrolling horizontally.
        let visibleDuration: TimeInterval = 4 * 60 * 60

        init(
            title: String,
            unit: String,
            averageText: String,
            averageValue: Double?,
            targetValue: Double,
            idealRange: ClosedRange<Double>,
            readings: [HistoricalMetricReading],
            fallbackDate: Date
        ) {
            self.title = title
            self.unit = unit
            self.averageText = averageText
            self.idealRange = idealRange

            self.averageIsIdeal =
                averageValue.map {
                    idealRange.contains($0)
                }
                ?? false

            let tenMinuteReadings = Self.makeTenMinuteReadings(
                from: readings
            )

            self.tenMinuteReadings = tenMinuteReadings
            
            self.lineSegments = zip(
                tenMinuteReadings,
                tenMinuteReadings.dropFirst()
            )
            .map { startReading, endReading in
                let startIsIdeal =
                    idealRange.contains(startReading.value)

                let endIsIdeal =
                    idealRange.contains(endReading.value)

                return LineSegment(
                    id:
                        "\(startReading.id.uuidString)-\(endReading.id.uuidString)",
                    start: startReading,
                    end: endReading,

                    // A complete segment is green only when both
                    // of its points are inside the ideal range.
                    isIdeal: startIsIdeal && endIsIdeal
                )
            }

            let firstTimestamp =
                tenMinuteReadings.first?.timestamp ?? fallbackDate

            // Begin the chart at the beginning of the first hour.
            let start =
                Calendar.current.dateInterval(
                    of: .hour,
                    for: firstTimestamp
                )?.start
                ?? firstTimestamp

            self.chartStart = start

            // Always provide at least four hours of chart space.
            let minimumEnd =
                Calendar.current.date(
                    byAdding: .hour,
                    value: 4,
                    to: start
                )
                ?? start.addingTimeInterval(4 * 60 * 60)

            if let lastTimestamp = tenMinuteReadings.last?.timestamp {
                let endOfLastHour =
                    Calendar.current.dateInterval(
                        of: .hour,
                        for: lastTimestamp
                    )?.end
                    ?? lastTimestamp

                self.chartEnd = max(
                    endOfLastHour,
                    minimumEnd
                )
            } else {
                self.chartEnd = minimumEnd
            }

            let values = readings.map(\.value) + [
                idealRange.lowerBound,
                idealRange.upperBound,
                targetValue
            ]

            let minimum = values.min() ?? targetValue
            let maximum = values.max() ?? targetValue

            let padding = max(
                (maximum - minimum) * 0.35,
                unit == "%" ? 5 : 2
            )

            self.yDomain =
                (minimum - padding)...(maximum + padding)
        }
        
        // MARK: - Ideal Status

        func isIdeal(
            _ reading: HistoricalMetricReading
        ) -> Bool {
            idealRange.contains(reading.value)
        }
        
        // MARK: - Selected Point

        func selectedReading(
            nearestTo selectedTimestamp: Date?
        ) -> HistoricalMetricReading? {
            guard let selectedTimestamp else {
                return nil
            }

            return tenMinuteReadings.min {
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

        func timestampText(
            for reading: HistoricalMetricReading
        ) -> String {
            reading.timestamp.formatted(
                date: .abbreviated,
                time: .shortened
            )
        }

        func valueText(
            for reading: HistoricalMetricReading
        ) -> String {
            formatted(reading.value) + unit
        }

        // Produces 24-hour clock labels:
        // 01.00, 13.00, 21.00, etc.
        func hourText(for date: Date) -> String {
            let components = Calendar.current.dateComponents(
                [.hour, .minute],
                from: date
            )

            let hour = components.hour ?? 0
            let minute = components.minute ?? 0

            return String(
                format: "%02d.%02d",
                hour,
                minute
            )
        }

        private func formatted(_ value: Double) -> String {
            if value.rounded() == value {
                return String(Int(value))
            }

            return String(format: "%.1f", value)
        }

        // MARK: - Ten-Minute Graph Points

        private static func makeTenMinuteReadings(
            from readings: [HistoricalMetricReading]
        ) -> [HistoricalMetricReading] {
            let sortedReadings = readings.sorted {
                $0.timestamp < $1.timestamp
            }

            let readingsByInterval = Dictionary(
                grouping: sortedReadings
            ) { reading in
                tenMinuteIntervalStart(
                    for: reading.timestamp
                )
            }

            return readingsByInterval.keys
                .sorted()
                .compactMap { intervalStart in
                    // Uses the first real database reading inside
                    // this 10-minute interval.
                    readingsByInterval[intervalStart]?.first
                }
        }

        private static func tenMinuteIntervalStart(
            for date: Date
        ) -> Date {
            let calendar = Calendar.current

            var components = calendar.dateComponents(
                [
                    .year,
                    .month,
                    .day,
                    .hour,
                    .minute
                ],
                from: date
            )

            let minute = components.minute ?? 0

            // Examples:
            // 13:03 becomes the 13:00 interval
            // 13:17 becomes the 13:10 interval
            // 13:58 becomes the 13:50 interval
            components.minute = (minute / 10) * 10
            components.second = 0

            return calendar.date(from: components) ?? date
        }
    }
}

// MARK: - Database Preview

#if DEBUG
@MainActor
final class HistoricalLogGraphPreviewViewModel: ObservableObject {
    @Published private(set) var summaryViewModel:
        ShipmentSummaryViewModel?

    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading = false

    func load() async {
        guard summaryViewModel == nil, !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            let shipments =
                try await ShipmentRepository().fetchAllShipments()

            guard let shipment = shipments.first else {
                errorMessage =
                    "No shipments were found in the database."
                return
            }

            let loadedViewModel = ShipmentSummaryViewModel(
                shipment: shipment
            )

            await loadedViewModel.loadSummaryData()

            if let loadingError = loadedViewModel.errorMessage {
                errorMessage = loadingError
                return
            }

            summaryViewModel = loadedViewModel
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
#endif
