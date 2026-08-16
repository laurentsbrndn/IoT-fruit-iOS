import Foundation
import Combine
import CoreLocation

// Pindahkan struct ini dari GraphView ke sini agar bisa diakses ViewModel
struct HistoricalMetricReading: Identifiable {
    let id: UUID
    let timestamp: Date
    let value: Double
}

@MainActor
final class ShipmentSummaryViewModel: ObservableObject {
    @Published private(set) var sensorLogs: [SensorLog] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    
    let shipment: Shipment
    private let sensorLogRepository: SensorLogRepositoryProtocol

    // MARK: - Konstanta Ideal (Dipindahkan dari GraphView)
    let temperatureTarget = 8.0
    let humidityTarget = 87.5
    let temperatureIdealRange: ClosedRange<Double> = 2...14
    let humidityIdealRange: ClosedRange<Double> = 85...90

    init(
        shipment: Shipment,
        sensorLogRepository: SensorLogRepositoryProtocol = SensorLogRepository()
    ) {
        self.shipment = shipment
        self.sensorLogRepository = sensorLogRepository
    }
    
    // MARK: - Shipment Header Presentation

    var shipmentIDText: String {
        "#\(shipment.id.uuidString.prefix(8).uppercased())"
    }

    var deviceNameText: String {
        shipment.device.name
    }

    var plateNumberText: String {
        shipment.truckPlateNumber
    }

    var contactText: String {
        "\(shipment.driver.name) \(shipment.driver.phoneNumber)"
    }

    // MARK: - Sensor Card Presentation

    var temperatureAverageText: String {
        temperatureText(averageTemperature)
    }

    var temperatureMinimumText: String {
        temperatureText(minimumTemperature)
    }

    var temperatureMaximumText: String {
        temperatureText(maximumTemperature)
    }

    var temperatureStatus: DeviceStatus {
        temperatureIsIdeal ? .ideal : .warning
    }

    var humidityAverageText: String {
        humidityText(averageHumidity)
    }

    var humidityMinimumText: String {
        humidityText(minimumHumidity)
    }

    var humidityMaximumText: String {
        humidityText(maximumHumidity)
    }

    var humidityStatus: DeviceStatus {
        humidityIsIdeal ? .ideal : .warning
    }

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

    // MARK: - Computed Properties untuk Logs
    var temperatureLogs: [SensorLog] { sensorLogs.filter { $0.temperature != nil && $0.timestamps != nil } }
    var humidityLogs: [SensorLog] { sensorLogs.filter { $0.humidity != nil && $0.timestamps != nil } }
    var locationLogs: [SensorLog] { sensorLogs.filter { $0.averageLatitude != nil && $0.averageLongitude != nil } }

    var averageTemperature: Double? { average(sensorLogs.compactMap(\.temperature)) }
    var minimumTemperature: Double? { sensorLogs.compactMap(\.temperature).min() }
    var maximumTemperature: Double? { sensorLogs.compactMap(\.temperature).max() }

    var averageHumidity: Double? { average(sensorLogs.compactMap(\.humidity)) }
    var minimumHumidity: Double? { sensorLogs.compactMap(\.humidity).min() }
    var maximumHumidity: Double? { sensorLogs.compactMap(\.humidity).max() }

    var temperatureIsIdeal: Bool {
        guard let value = averageTemperature else { return true }
        return temperatureIdealRange.contains(value)
    }

    var humidityIsIdeal: Bool {
        guard let value = averageHumidity else { return true }
        return humidityIdealRange.contains(value)
    }

    var tripDuration: String {
        guard let endDate = shipment.endDate else { return "In progress" }
        let seconds = max(0, Int(endDate.timeIntervalSince(shipment.startDate)))
        return String(format: "%02d:%02d:%02d", seconds / 3_600, (seconds % 3_600) / 60, seconds % 60)
    }
    
    // MARK: - Format Data untuk Tabel & Grafik
    var temperatureReadings: [HistoricalMetricReading] {
        sensorLogs.compactMap { log in
            guard let timestamp = log.timestamps, let value = log.temperature else { return nil }
            return HistoricalMetricReading(id: log.id, timestamp: timestamp, value: value)
        }
    }

    var humidityReadings: [HistoricalMetricReading] {
        sensorLogs.compactMap { log in
            guard let timestamp = log.timestamps, let value = log.humidity else { return nil }
            return HistoricalMetricReading(id: log.id, timestamp: timestamp, value: value)
        }
    }

    func temperatureText(_ value: Double?) -> String { formatted(value, suffix: "°C") }
    func humidityText(_ value: Double?) -> String { formatted(value, suffix: "%") }
    
    func tableLocationText(for log: SensorLog) -> String {
        guard let latitude = log.averageLatitude, let longitude = log.averageLongitude else { return "—" }
        return String(format: "%.4f, %.4f", latitude, longitude)
    }
    
    var destinationCoordinateText: String {
        guard let latitude = shipment.endLatitude, let longitude = shipment.endLongitude else { return "In progress" }
        return String(format: "%.4f, %.4f", latitude, longitude)
    }

    // MARK: - Koordinat Peta (Dipindahkan dari TripDetailsSheet)
    var startCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: shipment.startLatitude, longitude: shipment.startLongitude)
    }

    var endCoordinate: CLLocationCoordinate2D? {
        guard let latitude = shipment.endLatitude, let longitude = shipment.endLongitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var routeCoordinates: [CLLocationCoordinate2D] {
        let readings = locationLogs.compactMap { log -> CLLocationCoordinate2D? in
            guard let latitude = log.averageLatitude, let longitude = log.averageLongitude else { return nil }
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        return [startCoordinate] + readings + (endCoordinate.map { [$0] } ?? [])
    }

    // MARK: - Helper Methods
    // MARK: - Export
    func prepareCSVExport() -> URL? {
        do {
            return try makeCSVURL()
        } catch {
            errorMessage =
                "Could not create CSV: \(error.localizedDescription)"
            return nil
        }
    }

    func prepareGraphPNGExport(
        from pngData: Data?
    ) -> URL? {
        guard let pngData else {
            errorMessage = "Could not create graph image."
            return nil
        }

        let fileName =
            "Shipment_\(shipmentIDForFile)_Historical_Graph.png"

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName)

        do {
            try pngData.write(
                to: url,
                options: [.atomic]
            )

            return url
        } catch {
            errorMessage =
                "Could not save graph image: \(error.localizedDescription)"
            return nil
        }
    }

    private var shipmentIDForFile: String {
        String(
            shipment.id.uuidString
                .prefix(8)
                .uppercased()
        )
    }

    private func makeCSVURL() throws -> URL {
        var csv =
            "Timestamp,Temperature (°C),Humidity (%),Latitude,Longitude\n"

        for log in sensorLogs {
            let timestamp =
                log.timestamps?.toReadableString() ?? ""

            let temperature =
                log.temperature.map {
                    String(format: "%.1f", $0)
                } ?? ""

            let humidity =
                log.humidity.map {
                    String(format: "%.1f", $0)
                } ?? ""

            let latitude =
                log.averageLatitude.map {
                    String(format: "%.6f", $0)
                } ?? ""

            let longitude =
                log.averageLongitude.map {
                    String(format: "%.6f", $0)
                } ?? ""

            csv += [
                timestamp,
                temperature,
                humidity,
                latitude,
                longitude
            ]
            .map(csvValue)
            .joined(separator: ",")

            csv += "\n"
        }

        let fileName =
            "Shipment_\(shipmentIDForFile)_Historical_Log.csv"

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName)

        try csv.write(
            to: url,
            atomically: true,
            encoding: .utf8
        )

        return url
    }

    private func average(_ values: [Double]) -> Double? {
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / Double(values.count)
    }

    private func formatted(_ value: Double?, suffix: String) -> String {
        guard let value else { return "—" }
        let number = value.rounded() == value ? String(Int(value)) : String(format: "%.1f", value)
        return number + suffix
    }

    private func csvValue(_ value: String) -> String {
        "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
    }
}
