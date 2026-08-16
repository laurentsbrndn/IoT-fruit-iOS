import Foundation
import Combine
import CoreLocation

@MainActor
final class TripDetailsSheetViewModel: ObservableObject {
    let shipment: Shipment
    let locationLogs: [SensorLog]

    @Published var startDate: Date
    @Published var endDate: Date
    @Published private(set) var startLocationName = "Loading location…"
    @Published private(set) var endLocationName = "Loading location…"

    init(
        shipment: Shipment,
        locationLogs: [SensorLog]
    ) {
        self.shipment = shipment
        self.locationLogs = locationLogs
        self.startDate = shipment.startDate
        self.endDate = shipment.endDate ?? shipment.startDate
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

    var routeCoordinates: [CLLocationCoordinate2D] {
        let sensorCoordinates = locationLogs.compactMap { log -> CLLocationCoordinate2D? in
            guard
                let latitude = log.averageLatitude,
                let longitude = log.averageLongitude
            else {
                return nil
            }

            return CLLocationCoordinate2D(
                latitude: latitude,
                longitude: longitude
            )
        }

        return [startCoordinate]
            + sensorCoordinates
            + (endCoordinate.map { [$0] } ?? [])
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

    func updateStartDate(_ newDate: Date) {
        startDate = newDate

        if endDate < startDate {
            endDate = startDate
        }
    }

    func updateEndDate(_ newDate: Date) {
        endDate = max(newDate, startDate)
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
