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
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .padding(.top, 18)
            }
            .frame(minHeight: 350)

            HStack(alignment: .top, spacing: 16) {
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
        .padding(24)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
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
