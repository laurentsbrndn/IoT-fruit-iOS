//
//  Untitled.swift
//  BIKI LiveTrack
//
//  Created by Joana Mardas on 13/08/26.
//
//
//  TripDetailsSheet.swift
//  BIKI LiveTrack
//

import SwiftUI
import MapKit

struct TripDetailsSheet: View {
    let shipment: Shipment
    let duration: String
    let locationLogs: [SensorLog]

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button("Close", systemImage: "xmark") {
                    dismiss()
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.bordered)
                .buttonBorderShape(.circle)

                Spacer()

                Text("Trip Details")
                    .font(.app.heading2)
                    .foregroundColor(Color.theme.textPrimary)

                Spacer()
                Color.clear.frame(width: 36, height: 36)
            }

            ZStack(alignment: .top) {
                RouteMapView(
                    startCoordinate: startCoordinate,
                    endCoordinate: endCoordinate,
                    routeCoordinates: routeCoordinates
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))

                VStack(spacing: 4) {
                    Text("Trip Duration")
                        .font(.app.bodyBold)
                    Text(duration)
                        .font(.system(size: 38, weight: .regular))
                        .monospacedDigit()
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .padding(.top, 18)
            }
            .frame(minHeight: 350)

            HStack(alignment: .top, spacing: 16) {
                LocationSummaryCard(
                    title: "Start Location",
                    date: shipment.startDate,
                    coordinate: startCoordinate
                )
                LocationSummaryCard(
                    title: "End Location",
                    date: shipment.endDate,
                    coordinate: endCoordinate
                )
            }
        }
        .padding(24)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var startCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: shipment.startLatitude, longitude: shipment.startLongitude)
    }

    private var endCoordinate: CLLocationCoordinate2D? {
        guard let latitude = shipment.endLatitude, let longitude = shipment.endLongitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    private var routeCoordinates: [CLLocationCoordinate2D] {
        let readings = locationLogs.compactMap { log -> CLLocationCoordinate2D? in
            guard let latitude = log.averageLatitude, let longitude = log.averageLongitude else { return nil }
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        return [startCoordinate] + readings + (endCoordinate.map { [$0] } ?? [])
    }
}

private struct LocationSummaryCard: View {
    let title: String
    let date: Date?
    let coordinate: CLLocationCoordinate2D?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.app.title1)
                .foregroundColor(Color.theme.primaryGreen)
            Text(date?.toReadableString() ?? "In progress")
                .font(.app.bodyBold)
            Text(coordinate.map { String(format: "%.4f, %.4f", $0.latitude, $0.longitude) } ?? "—")
                .font(.app.caption)
                .foregroundColor(Color.theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Color.theme.grey)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct RouteMapView: UIViewRepresentable {
    let startCoordinate: CLLocationCoordinate2D
    let endCoordinate: CLLocationCoordinate2D?
    let routeCoordinates: [CLLocationCoordinate2D]

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.isRotateEnabled = false
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        map.removeAnnotations(map.annotations)
        map.removeOverlays(map.overlays)

        let start = MKPointAnnotation()
        start.coordinate = startCoordinate
        start.title = "Start"
        map.addAnnotation(start)

        if let endCoordinate {
            let end = MKPointAnnotation()
            end.coordinate = endCoordinate
            end.title = "Destination"
            map.addAnnotation(end)
        }

        if routeCoordinates.count > 1 {
            let route = MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
            map.addOverlay(route)
            map.setVisibleMapRect(route.boundingMapRect, edgePadding: UIEdgeInsets(top: 70, left: 50, bottom: 50, right: 50), animated: false)
        } else {
            map.setRegion(MKCoordinateRegion(center: startCoordinate, latitudinalMeters: 8_000, longitudinalMeters: 8_000), animated: false)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let route = overlay as? MKPolyline else { return MKOverlayRenderer(overlay: overlay) }
            let renderer = MKPolylineRenderer(polyline: route)
            renderer.strokeColor = UIColor(Color.theme.primaryGreen)
            renderer.lineWidth = 7
            return renderer
        }
    }
}

#Preview("Trip Details", traits: .landscapeLeft) {
    TripDetailsSheet(
        shipment: ShipmentSummaryPreviewData.shipment,
        duration: "15:55:00",
        locationLogs: ShipmentSummaryPreviewData.sensorLogs
    )
    .frame(width: 1_050, height: 720)
}
