//
//  TripDetailsSheet.swift
//  BIKI LiveTrack
//
//  Created by Joana Mardas on 13/08/26.
//

import SwiftUI
import MapKit

struct TripDetailsSheet: View {
    @ObservedObject var viewModel: ShipmentSummaryViewModel
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
                    startCoordinate: viewModel.startCoordinate,
                    endCoordinate: viewModel.endCoordinate,
                    routeCoordinates: viewModel.routeCoordinates
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))

                VStack(spacing: 4) {
                    Text("Trip Duration")
                        .font(.app.bodyBold)
                    Text(viewModel.tripDuration)
                        .font(.system(size: 38, weight: .regular))
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
                    date: viewModel.shipment.startDate,
                    coordinate: viewModel.startCoordinate
                )
                LocationSummaryCard(
                    title: "End Location",
                    date: viewModel.shipment.endDate,
                    coordinate: viewModel.endCoordinate
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
            
            Text(date?.toReadableString() ?? "In progress")
                .font(.app.bodyBold)
            
            // Perubahan ada di blok ini:
            // Menggunakan LocationLabelComponent untuk mendapatkan nama lokasi
            if let coord = coordinate {
                LocationLabelComponent(latitude: coord.latitude, longitude: coord.longitude)
                    .font(.app.caption)
                    .foregroundColor(Color.theme.textSecondary)
            } else {
                Text("—")
                    .font(.app.caption)
                    .foregroundColor(Color.theme.textSecondary)
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
