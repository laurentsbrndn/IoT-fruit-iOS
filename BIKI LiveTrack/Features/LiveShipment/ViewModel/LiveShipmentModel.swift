//
//  LiveShipmentViewModel.swift
//  BIKI LiveTrack
//

import Foundation
import Combine
import CoreLocation

@MainActor

struct LiveChartReading: Identifiable {
    let id: UUID
    let timestamp: Date
    let value: Double
}
final class LiveShipmentViewModel: ObservableObject {
    
    @Published private(set) var sensorLogs: [SensorLog] = []
    @Published private(set) var alerts: [AlertLog] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    
    @Published var currentTemperature: Double?
    @Published var currentHumidity: Double?
    @Published var lastUpdatedTimestamp: Date?
    
    @Published private(set) var startLocationName = "Loading location…"
    @Published private(set) var currentLocationName = "Loading location…"
    
    @Published var shipment: Shipment
    
    private let sensorLogRepository: SensorLogRepositoryProtocol
    private let alertLogRepository: AlertLogRepositoryProtocol
    private let shipmentRepository: ShipmentRepositoryProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        shipment: Shipment,
        sensorLogRepository: SensorLogRepositoryProtocol = SensorLogRepository(),
        alertLogRepository: AlertLogRepositoryProtocol = AlertLogRepository(),
        shipmentRepository: ShipmentRepositoryProtocol = ShipmentRepository()
    ) {
        self.shipment = shipment
        self.sensorLogRepository = sensorLogRepository
        self.alertLogRepository = alertLogRepository
        self.shipmentRepository = shipmentRepository
        
        setupWebSocketListener()
    }
    
    func loadLiveShipmentData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let fetchSensors = sensorLogRepository.fetchSensors(byShipmentID: shipment.id.uuidString)
            async let fetchAlerts = alertLogRepository.fetchAlerts(byShipmentID: shipment.id.uuidString)
            async let fetchShipment = shipmentRepository.fetchShipmentDetail(id: shipment.id.uuidString)
            
            let (logs, alertLogs, updatedShipment) = try await (fetchSensors, fetchAlerts, fetchShipment)
            
            self.shipment = updatedShipment
            
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
            
            await loadLiveLocationNames()
            
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
        let effectiveStartDate = sensorLogs.first?.timestamps ?? shipment.startDate
        let endDate = shipment.endDate ?? now
        let timeInterval = endDate.timeIntervalSince(effectiveStartDate)
        
        let seconds = timeInterval < 0 ? Int(now.timeIntervalSince(effectiveStartDate.addingTimeInterval(abs(timeInterval)))) : Int(timeInterval)
        let finalSeconds = max(0, seconds)
        
        let days = finalSeconds / 86_400
        let remainingSeconds = finalSeconds % 86_400
        
        let hours = remainingSeconds / 3_600
        let minutes = (remainingSeconds % 3_600) / 60
        let secs = remainingSeconds % 60
        
        let timeString = String(format: "%02d:%02d:%02d", hours, minutes, secs)
        
        if days == 0 {
            return timeString
        } else if days == 1 {
            return "1 day, \(timeString)"
        } else {
            return "\(days) days, \(timeString)"
        }
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
    
    // MARK: - Live Graph Data
    
    let temperatureIdealRange: ClosedRange<Double> = 10...13
    let humidityIdealRange: ClosedRange<Double> = 85...90
    
    var temperatureChartReadings: [LiveChartReading] {
        makeTenMinuteReadings { log in
            log.temperature
        }
    }
    
    var humidityChartReadings: [LiveChartReading] {
        makeTenMinuteReadings { log in
            log.humidity
        }
    }
    
    private func makeTenMinuteReadings(
        value: (SensorLog) -> Double?
    ) -> [LiveChartReading] {
        let validReadings = sensorLogs.compactMap { log -> LiveChartReading? in
            guard
                let timestamp = log.timestamps,
                let sensorValue = value(log)
            else {
                return nil
            }
            
            return LiveChartReading(
                id: log.id,
                timestamp: timestamp,
                value: sensorValue
            )
        }
            .sorted {
                $0.timestamp < $1.timestamp
            }
        
        let groupedReadings = Dictionary(
            grouping: validReadings
        ) { reading in
            tenMinuteIntervalStart(for: reading.timestamp)
        }
        
        return groupedReadings.keys
            .sorted()
            .compactMap { interval in
                // The latest real database value in each 10-minute interval.
                groupedReadings[interval]?.last
            }
    }
    
    private func tenMinuteIntervalStart(for date: Date) -> Date {
        let calendar = Calendar.current
        
        var components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        
        let minute = components.minute ?? 0
        
        components.minute = (minute / 10) * 10
        components.second = 0
        
        return calendar.date(from: components) ?? date
    }
    
    private var latestSensorCoordinate: CLLocationCoordinate2D? {
        for log in sensorLogs.reversed() {
            guard
                let latitude = log.averageLatitude,
                let longitude = log.averageLongitude
            else {
                continue
            }
            
            let coordinate = CLLocationCoordinate2D(
                latitude: latitude,
                longitude: longitude
            )
            
            // Ignore impossible or empty coordinates.
            guard CLLocationCoordinate2DIsValid(coordinate) else {
                continue
            }
            
            guard latitude != 0 || longitude != 0 else {
                continue
            }
            
            return coordinate
        }
        
        return nil
    }
    
    var currentRouteCoordinate: CLLocationCoordinate2D {
        latestSensorCoordinate ?? startCoordinate
    }
    
    var liveRouteCoordinates: [CLLocationCoordinate2D] {
        let currentCoordinate = currentRouteCoordinate
        
        if coordinatesAreEqual(
            startCoordinate,
            currentCoordinate
        ) {
            return [startCoordinate]
        }
        
        return [
            startCoordinate,
            currentCoordinate
        ]
    }
    
    private func coordinatesAreEqual(
        _ first: CLLocationCoordinate2D,
        _ second: CLLocationCoordinate2D
    ) -> Bool {
        let tolerance = 0.000001
        
        return
        abs(first.latitude - second.latitude) < tolerance
        &&
        abs(first.longitude - second.longitude) < tolerance
    }
    
    func loadLiveLocationNames() async {
        let resolvedStartName =
        await locationName(for: startCoordinate)
        
        let resolvedCurrentName =
        await locationName(for: currentRouteCoordinate)
        
        startLocationName = resolvedStartName
        currentLocationName = resolvedCurrentName
    }
    
    private func locationName(
        for coordinate: CLLocationCoordinate2D
    ) async -> String {
        let location = CLLocation(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
        
        do {
            let placemarks =
            try await CLGeocoder()
                .reverseGeocodeLocation(location)
            
            guard let placemark = placemarks.first else {
                return coordinateText(coordinate)
            }
            
            let addressParts = [
                placemark.name,
                placemark.locality
                ?? placemark.subAdministrativeArea
            ]
                .compactMap { $0 }
                .filter { !$0.isEmpty }
            
            if addressParts.isEmpty {
                return coordinateText(coordinate)
            }
            
            return addressParts.joined(separator: ", ")
        } catch {
            return coordinateText(coordinate)
        }
    }
    
    private func coordinateText(
        _ coordinate: CLLocationCoordinate2D
    ) -> String {
        String(
            format: "%.4f, %.4f",
            coordinate.latitude,
            coordinate.longitude
        )
    }
}
