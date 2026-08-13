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
    @State private var startDate: Date
    @State private var endDate: Date

    init(shipment: Shipment, duration: String, locationLogs: [SensorLog]) {
        self.shipment = shipment
        self.duration = duration
        self.locationLogs = locationLogs
        _startDate = State(initialValue: shipment.startDate)
        _endDate = State(initialValue: shipment.endDate ?? shipment.startDate)
    }

    var body: some View {
        VStack(spacing: 10) {
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
                        .font(.system(size: 20, weight: .regular))
                    Text(updatedDuration)
                        .font(.system(size: 34, weight: .regular))
                        .monospacedDigit()
                }
                .frame(width: 214, height: 92)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
                .padding(.top, 18)
            }
            .frame(minHeight: 350, maxHeight: .infinity)

            HStack(alignment: .top, spacing: 18) {
                LocationSummaryCard(
                    title: "Start Location",
                    date: $startDate,
                    coordinate: startCoordinate
                )
                LocationSummaryCard(
                    title: "End Location",
                    date: $endDate,
                    minimumDate: startDate,
                    coordinate: endCoordinate
                )
            }
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 24)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onChange(of: startDate) { _, newStartDate in
            if endDate < newStartDate {
                endDate = newStartDate
            }
        }
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

    private var updatedDuration: String {
        let seconds = max(0, Int(endDate.timeIntervalSince(startDate)))
        return String(format: "%02d:%02d:%02d", seconds / 3_600, (seconds % 3_600) / 60, seconds % 60)
    }
}

private struct LocationSummaryCard: View {
    let title: String
    @Binding var date: Date
    var minimumDate: Date? = nil
    let coordinate: CLLocationCoordinate2D?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .tracking(-0.45)
                .foregroundColor(Color.theme.primaryGreen)

            HStack(spacing: 16) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(Color.theme.primaryGreen)

                EditableDateControl(date: $date, minimumDate: minimumDate)
            }

            HStack(alignment: .top, spacing: 16) {
                Image(systemName: "mappin")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(Color.theme.primaryGreen)

                Text(coordinate.map { String(format: "%.4f, %.4f", $0.latitude, $0.longitude) } ?? "—")
                    .font(.system(size: 20, weight: .regular))
                    .tracking(-0.45)
                    .foregroundColor(Color.theme.textPrimary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 160)
        .padding(24)
        .background(Color.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(color: .black.opacity(0.1), radius: 4, y: 4)
    }
}

private struct EditableDateControl: View {
    @Binding var date: Date
    let minimumDate: Date?

    @State private var isShowingCalendar = false

    var body: some View {
        Button {
            isShowingCalendar = true
        } label: {
            HStack(spacing: 10) {
                Text(date.toReadableString())
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(Color.theme.textPrimary)

                Spacer(minLength: 0)

                Image(systemName: "chevron.down")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.theme.textSecondary)
            }
            .padding(.horizontal, 11)
            .padding(.vertical, 6)
            .background(Color(uiColor: .tertiarySystemFill), in: Capsule())
        }
        .buttonStyle(.plain)
        .popover(isPresented: $isShowingCalendar, arrowEdge: .bottom) {
            VStack(spacing: 12) {
                DatePicker(
                    "Date",
                    selection: $date,
                    in: availableDates,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .labelsHidden()

                Divider()

                HStack {
                    Text("Time")
                        .font(.app.body)
                        .foregroundColor(Color.theme.textPrimary)

                    Spacer()

                    DatePicker(
                        "Time",
                        selection: $date,
                        in: availableDates,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .tint(Color.theme.primaryGreen)
                }
            }
            .padding(16)
            .frame(width: 360)
        }
        .accessibilityLabel("Edit date and time")
    }

    private var availableDates: PartialRangeFrom<Date> {
        minimumDate.map { $0... } ?? Date.distantPast...
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
