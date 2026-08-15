//
//  LiveShipmentViewModel.swift
//  BIKI LiveTrack
//

import Foundation
import Combine
import CoreLocation

@MainActor
final class LiveShipmentViewModel: ObservableObject {
    
    @Published private(set) var sensorLogs: [SensorLog] = []
    @Published private(set) var alerts: [AlertLog] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    
    @Published var currentTemperature: Double?
    @Published var currentHumidity: Double?
    @Published var lastUpdatedTimestamp: Date?
    
    let shipment: Shipment
    private let sensorLogRepository: SensorLogRepositoryProtocol
    private let alertLogRepository: AlertLogRepositoryProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        shipment: Shipment,
        sensorLogRepository: SensorLogRepositoryProtocol = SensorLogRepository(),
        alertLogRepository: AlertLogRepositoryProtocol = AlertLogRepository()
    ) {
        self.shipment = shipment
        self.sensorLogRepository = sensorLogRepository
        self.alertLogRepository = alertLogRepository
        
        setupWebSocketListener()
    }
    
    func loadLiveShipmentData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let fetchSensors = sensorLogRepository.fetchSensors(byShipmentID: shipment.id.uuidString)
            async let fetchAlerts = alertLogRepository.fetchAlerts(byShipmentID: shipment.id.uuidString)
            
            let (logs, alertLogs) = try await (fetchSensors, fetchAlerts)
            
            self.sensorLogs = logs.sorted {
                ($0.timestamps ?? .distantPast) < ($1.timestamps ?? .distantPast)
            }
            self.alerts = alertLogs.sorted {
                $0.timestamps > $1.timestamps
            }
            
            if let latest = self.sensorLogs.last {
                self.currentTemperature = latest.temperature
                self.currentHumidity = latest.humidity
                self.lastUpdatedTimestamp = latest.timestamps
            }
            
        } catch {
            errorMessage = error.localizedDescription
            print("🚨 GAGAL FETCH DATA: \(error)")
        }
        
        isLoading = false
    }
    
    private func setupWebSocketListener() {
        WebSocketManager.shared.connect()
        
        WebSocketManager.shared.$latestTelemetry
            .compactMap { $0 }
            .filter { [weak self] telemetry in
                guard let self = self else { return false }
                return telemetry.deviceId.lowercased() == self.shipment.device.id.uuidString.lowercased()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] telemetry in
                if let latestItem = telemetry.log.last {
                    if let temp = latestItem.temperature {
                        self?.currentTemperature = temp
                    }
                    if let hum = latestItem.humidity {
                        self?.currentHumidity = hum
                    }
                    self?.lastUpdatedTimestamp = Date()
                    
                    Task {
                        await self?.loadLiveShipmentData()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    var temperatureProgress: Double {
        guard let temp = currentTemperature else { return 0.0 }
        return min(max(temp / 40.0, 0.0), 1.0)
    }
    
    var humidityProgress: Double {
        guard let hum = currentHumidity else { return 0.0 }
        return min(max(hum / 100.0, 0.0), 1.0)
    }
    
    var temperatureIsIdeal: Bool {
        guard let temp = currentTemperature else { return true }
        return (10...13).contains(temp)
    }
    
    var humidityIsIdeal: Bool {
        guard let hum = currentHumidity else { return true }
        return (85...95).contains(hum)
    }
    
    var temperatureStatus: DeviceStatus {
        guard currentTemperature != nil else { return .offline }
        return temperatureIsIdeal ? .ideal : .warning
    }
    
    var humidityStatus: DeviceStatus {
        guard currentHumidity != nil else { return .offline }
        return humidityIsIdeal ? .ideal : .warning
    }
    
    var startCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: shipment.startLatitude, longitude: shipment.startLongitude)
    }
    
    var endCoordinate: CLLocationCoordinate2D? {
        guard let latitude = shipment.endLatitude, let longitude = shipment.endLongitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var shipmentIDText: String {
        "#\(shipment.id.uuidString.prefix(8).uppercased())"
    }
    
    var deviceIDText: String { shipment.device.name }
    var plateNumberText: String { shipment.truckPlateNumber }
    var contactText: String { "\(shipment.driver.name) \(shipment.driver.phoneNumber)" }
    
    var lastUpdatedTimeText: String {
        guard let lastTimestamp = lastUpdatedTimestamp else { return "--:--" }
        return lastTimestamp.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits))
    }
    
    var temperatureValueText: String {
        currentTemperature != nil ? formatted(currentTemperature, suffix: "°C") : "--°C"
    }
    
    var humidityValueText: String {
        currentHumidity != nil ? formatted(currentHumidity, suffix: "%") : "--%"
    }
    
    func tripDuration(asOf now: Date = Date()) -> String {
        // Ambil timestamp dari sensor log pertama sebagai alternatif start time jika shipment.startDate bermasalah di DB
        let effectiveStartDate = sensorLogs.first?.timestamps ?? shipment.startDate
        
        let endDate = shipment.endDate ?? now
        
        let timeInterval = endDate.timeIntervalSince(effectiveStartDate)
        
        let seconds = timeInterval < 0 ? Int(now.timeIntervalSince(effectiveStartDate.addingTimeInterval(abs(timeInterval)))) : Int(timeInterval)
        
        let finalSeconds = max(0, seconds)
        
        return String(format: "%02d:%02d:%02d", finalSeconds / 3_600, (finalSeconds % 3_600) / 60, finalSeconds % 60)
    }
    
    func formatTimeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func formatted(_ value: Double?, suffix: String) -> String {
        guard let value else { return "--" + suffix }
        let number = value.rounded() == value
        ? String(Int(value))
        : String(format: "%.1f", value)
        return number + suffix
    }
}
