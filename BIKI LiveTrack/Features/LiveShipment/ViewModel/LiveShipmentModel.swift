//
//  LiveShipmentModel.swift
//  BIKI LiveTrack
//
//  Created by Grace Frendy on 13/08/26.
//


import Foundation
import Combine

@MainActor
final class LiveShipmentViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published private(set) var sensorLogs: [SensorLog] = []
    @Published private(set) var alerts: [AlertLog] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    
    let shipment: Shipment
    private let sensorLogRepository: SensorLogRepositoryProtocol
    private let alertLogRepository: AlertLogRepositoryProtocol

    // MARK: - Initializer
    
    init(
        shipment: Shipment,
        sensorLogRepository: SensorLogRepositoryProtocol = SensorLogRepository(),
        alertLogRepository: AlertLogRepositoryProtocol = AlertLogRepository()
    ) {
        self.shipment = shipment
        self.sensorLogRepository = sensorLogRepository
        self.alertLogRepository = alertLogRepository
    }

    // MARK: - Data Fetching
    
    func loadLiveShipmentData() async {
        isLoading = true
        errorMessage = nil

        do {
            async let fetchSensors = sensorLogRepository.fetchSensors(byShipmentID: shipment.id.uuidString)
            async let fetchAlerts = alertLogRepository.fetchAlerts(byShipmentID: shipment.id.uuidString)
            
            let (logs, alertLogs) = try await (fetchSensors, fetchAlerts)
            print("Sensor Logs count: \(logs.count)")
            print("Alert Logs count: \(alertLogs.count)") // Cek apakah bernilai 0
            
            self.sensorLogs = logs.sorted {
                ($0.timestamps ?? .distantPast) < ($1.timestamps ?? .distantPast)
            }
            self.alerts = alertLogs.sorted {
                ($0.timestamps) > ($1.timestamps)
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Latest Sensor Readings
    
    private var latestLog: SensorLog? {
        sensorLogs.last
    }

    var currentTemperature: Double? {
        latestLog?.temperature
    }

    var currentHumidity: Double? {
        latestLog?.humidity
    }

    var temperatureProgress: Double {
        guard let temp = currentTemperature else { return 0.5 }
        return min(max(temp / 40.0, 0.0), 1.0)
    }

    var humidityProgress: Double {
        guard let hum = currentHumidity else { return 0.0 }
        return min(max(hum / 100.0, 0.0), 1.0)
    }

    // MARK: - Status Checks
    
    var temperatureIsIdeal: Bool {
        guard let temp = currentTemperature else { return true }
        return (2...14).contains(temp)
    }

    var humidityIsIdeal: Bool {
        guard let hum = currentHumidity else { return true }
        return (85...90).contains(hum)
    }

    var temperatureStatus: DeviceStatus {
        guard currentTemperature != nil else { return .ideal }
        return temperatureIsIdeal ? .ideal : .warning
    }

    var humidityStatus: DeviceStatus {
        guard currentHumidity != nil else { return .offline }
        return humidityIsIdeal ? .ideal : .warning
    }

    
    var shipmentIDText: String {
        "#\(shipment.id.uuidString.prefix(8).uppercased())"
    }

    var deviceIDText: String { shipment.device.name }
    var plateNumberText: String { shipment.truckPlateNumber }
    var contactText: String { "\(shipment.driver.name) \(shipment.driver.phoneNumber)" }
    
    var originText: String {
        "BIKI point SMG"
    }
    
    var destinationText: String {
        "Ranch Market BSD, Tangerang Selatan 11890"
    }

    var lastUpdatedTimeText: String {
        guard let lastTimestamp = latestLog?.timestamps else { return "23:90" }
        return lastTimestamp.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits))
    }

    var temperatureValueText: String {
        currentTemperature != nil ? formatted(currentTemperature, suffix: "°C") : "10°C"
    }
    
    var humidityValueText: String {
        currentHumidity != nil ? formatted(currentHumidity, suffix: "%") : "0%"
    }

    var tripDuration: String {
        let endDate = shipment.endDate ?? Date()
        let seconds = max(0, Int(endDate.timeIntervalSince(shipment.startDate)))
        return String(format: "%02d:%02d:%02d", seconds / 3_600, (seconds % 3_600) / 60, seconds % 60)
    }

    // MARK: - Helper Methods
    
    func formatTimeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    private func formatted(_ value: Double?, suffix: String) -> String {
        guard let value else { return "0" + suffix }
        let number = value.rounded() == value
            ? String(Int(value))
            : String(format: "%.1f", value)
        return number + suffix
    }
}
