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
            targetValue: summaryViewModel.humidityTarget,
            idealRange: summaryViewModel.humidityIdealRange,
            readings: summaryViewModel.humidityReadings,
            fallbackDate: summaryViewModel.shipment.startDate
        )
    }
}

// MARK: - One Graph

extension HistoricalLogGraphViewModel {
    struct Metric {
        let title: String
        let unit: String
        let averageText: String
        let idealRange: ClosedRange<Double>

        let hourlyReadings: [HistoricalMetricReading]
        let chartStart: Date
        let chartEnd: Date
        let yDomain: ClosedRange<Double>

        let visibleDuration: TimeInterval = 4 * 60 * 60

        init(
            title: String,
            unit: String,
            averageText: String,
            targetValue: Double,
            idealRange: ClosedRange<Double>,
            readings: [HistoricalMetricReading],
            fallbackDate: Date
        ) {
            self.title = title
            self.unit = unit
            self.averageText = averageText
            self.idealRange = idealRange

            let hourlyReadings = Self.makeHourlyReadings(
                from: readings
            )

            self.hourlyReadings = hourlyReadings

            let firstTimestamp =
                hourlyReadings.first?.timestamp ?? fallbackDate

            let start =
                Calendar.current.dateInterval(
                    of: .hour,
                    for: firstTimestamp
                )?.start
                ?? firstTimestamp

            self.chartStart = start

            let minimumEnd =
                Calendar.current.date(
                    byAdding: .hour,
                    value: 4,
                    to: start
                )
                ?? start.addingTimeInterval(4 * 60 * 60)

            if let lastTimestamp = hourlyReadings.last?.timestamp {
                let endOfLastHour =
                    Calendar.current.dateInterval(
                        of: .hour,
                        for: lastTimestamp
                    )?.end
                    ?? lastTimestamp

                self.chartEnd = max(endOfLastHour, minimumEnd)
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

        func selectedReading(
            nearestTo selectedTimestamp: Date?
        ) -> HistoricalMetricReading? {
            guard let selectedTimestamp else {
                return nil
            }

            return hourlyReadings.min {
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

        private func formatted(_ value: Double) -> String {
            if value.rounded() == value {
                return String(Int(value))
            }

            return String(format: "%.1f", value)
        }

        private static func makeHourlyReadings(
            from readings: [HistoricalMetricReading]
        ) -> [HistoricalMetricReading] {
            readings.sorted {
                $0.timestamp < $1.timestamp
            }
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
