//
//  ShipmentSummaryViewModel.swift
//  BIKI LiveTrack
//
//  Created by Joana Mardas on 13/08/26.
//
//
//  ShipmentSummaryViewModel.swift
//  BIKI LiveTrack
//

import Foundation
import Combine

@MainActor
final class ShipmentSummaryViewModel: ObservableObject {
    @Published private(set) var sensorLogs: [SensorLog] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    let shipment: Shipment
    private let sensorLogRepository: SensorLogRepositoryProtocol

    init(
        shipment: Shipment,
        sensorLogRepository: SensorLogRepositoryProtocol = SensorLogRepository()
    ) {
        self.shipment = shipment
        self.sensorLogRepository = sensorLogRepository
    }

    // The screen calls this once when it appears. Keeping the API call here
    // means the SwiftUI view only has to worry about displaying data.
    func loadSummaryData() async {
        isLoading = true
        errorMessage = nil

        do {
            let logs = try await sensorLogRepository.fetchSensors(byShipmentID: shipment.id.uuidString)
            sensorLogs = logs.sorted {
                ($0.timestamps ?? .distantPast) < ($1.timestamps ?? .distantPast)
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    var temperatureLogs: [SensorLog] { sensorLogs.filter { $0.temperature != nil && $0.timestamps != nil } }
    var humidityLogs: [SensorLog] { sensorLogs.filter { $0.humidity != nil && $0.timestamps != nil } }
    var locationLogs: [SensorLog] { sensorLogs.filter { $0.averageLatitude != nil && $0.averageLongitude != nil } }

    var averageTemperature: Double? { average(sensorLogs.compactMap(\.temperature)) }
    var minimumTemperature: Double? { sensorLogs.compactMap(\.temperature).min() }
    var maximumTemperature: Double? { sensorLogs.compactMap(\.temperature).max() }

    var averageHumidity: Double? { average(sensorLogs.compactMap(\.humidity)) }
    var minimumHumidity: Double? { sensorLogs.compactMap(\.humidity).min() }
    var maximumHumidity: Double? { sensorLogs.compactMap(\.humidity).max() }

    // Mango storage recommendations supplied by the team: 2–14°C and 85–90% humidity.
    var temperatureIsIdeal: Bool {
        guard let value = averageTemperature else { return true }
        return (2...14).contains(value)
    }

    var humidityIsIdeal: Bool {
        guard let value = averageHumidity else { return true }
        return (85...90).contains(value)
    }

    var tripDuration: String {
        guard let endDate = shipment.endDate else { return "In progress" }
        let seconds = max(0, Int(endDate.timeIntervalSince(shipment.startDate)))
        return String(format: "%02d:%02d:%02d", seconds / 3_600, (seconds % 3_600) / 60, seconds % 60)
    }

    func temperatureText(_ value: Double?) -> String { formatted(value, suffix: "°C") }
    func humidityText(_ value: Double?) -> String { formatted(value, suffix: "%") }

    func generateCSVURL() throws -> URL {
        var csv = "Timestamp,Temperature (°C),Humidity (%),Latitude,Longitude\n"

        for log in sensorLogs {
            let timestamp = log.timestamps?.toReadableString() ?? ""
            let temperature = log.temperature.map { String(format: "%.1f", $0) } ?? ""
            let humidity = log.humidity.map { String(format: "%.1f", $0) } ?? ""
            let latitude = log.averageLatitude.map { String(format: "%.6f", $0) } ?? ""
            let longitude = log.averageLongitude.map { String(format: "%.6f", $0) } ?? ""

            csv += [timestamp, temperature, humidity, latitude, longitude]
                .map(csvValue)
                .joined(separator: ",") + "\n"
        }

        let shipmentID = shipment.id.uuidString.prefix(8).uppercased()
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("Shipment_\(shipmentID)_Historical_Log.csv")
        try csv.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    private func average(_ values: [Double]) -> Double? {
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / Double(values.count)
    }

    private func formatted(_ value: Double?, suffix: String) -> String {
        guard let value else { return "—" }
        let number = value.rounded() == value
            ? String(Int(value))
            : String(format: "%.1f", value)
        return number + suffix
    }

    private func csvValue(_ value: String) -> String {
        "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
    }
}
