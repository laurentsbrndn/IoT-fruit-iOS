import Foundation
import Combine
import CoreLocation

@MainActor
final class TripDetailsSheetViewModel: ObservableObject {
    let shipment: Shipment
    let locationLogs: [SensorLog]
    let startDate: Date
    let endDate: Date
    @Published private(set) var startLocationName = "Loading location…"
    @Published private(set) var endLocationName = "Loading location…"

    init(
        shipment: Shipment,
        locationLogs: [SensorLog]
    ) {
        self.shipment = shipment
        self.locationLogs = locationLogs

        let timestamps = locationLogs
            .compactMap(\.timestamps)
            .sorted()

        let resolvedStartDate = shipment.startDate

        let resolvedEndDate =
            shipment.endDate
            ?? timestamps.last
            ?? resolvedStartDate

        self.startDate = resolvedStartDate
        self.endDate = resolvedEndDate
    }

    var startCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: shipment.startLatitude,
            longitude: shipment.startLongitude
        )
    }

    var endCoordinate: CLLocationCoordinate2D? {
        guard
            let latitude = shipment.endLatitude,
            let longitude = shipment.endLongitude
        else {
            return nil
        }

        return CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }

    // MARK: - PERUBAHAN LOGIKA ROUTE (GARIS HIJAU)
    var routeCoordinates: [CLLocationCoordinate2D] {
        // 1. Mulai dari titik keberangkatan
        var coords = [startCoordinate]
        
        // 2. Tambahkan seluruh jejak dari tabel sensor_logs yang riil
        let validLogs = locationLogs.compactMap { log -> CLLocationCoordinate2D? in
            guard let lat = log.averageLatitude, let lon = log.averageLongitude else { return nil }
            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            
            // Pastikan titik koordinat valid dan bukan 0,0
            guard CLLocationCoordinate2DIsValid(coord), (lat != 0 || lon != 0) else { return nil }
            return coord
        }
        
        coords.append(contentsOf: validLogs)
        
        // 3. Akhiri tepat di titik destinasi (jika sudah ada)
        if let endCoordinate = endCoordinate {
            coords.append(endCoordinate)
        }

        return coords
    }

    var tripDuration: String {
        let seconds = max(0, Int(endDate.timeIntervalSince(startDate)))

        return String(
            format: "%02d:%02d:%02d",
            seconds / 3_600,
            (seconds % 3_600) / 60,
            seconds % 60
        )
    }

    func loadLocationNames() async {
        startLocationName = await locationName(for: startCoordinate)

        if let endCoordinate {
            endLocationName = await locationName(for: endCoordinate)
        } else {
            endLocationName = "In progress"
        }
    }

    private func locationName(for coordinate: CLLocationCoordinate2D) async -> String {
        let location = CLLocation(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )

        do {
            let placemarks = try await CLGeocoder().reverseGeocodeLocation(location)

            guard let place = placemarks.first else {
                return coordinateText(coordinate)
            }

            let parts = [
                place.name,
                place.locality ?? place.subAdministrativeArea
            ]
            .compactMap { $0 }
            .filter { !$0.isEmpty }

            return parts.isEmpty
                ? coordinateText(coordinate)
                : parts.joined(separator: ", ")
        } catch {
            return coordinateText(coordinate)
        }
    }

    private func coordinateText(_ coordinate: CLLocationCoordinate2D) -> String {
        String(
            format: "%.4f, %.4f",
            coordinate.latitude,
            coordinate.longitude
        )
    }
}
