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
        // These titles are rendered as persistent labels above their pins,
        // matching the Start Point and Destination labels in the Figma sheet.
        start.title = "Start Point"
        start.subtitle = "Start Location"
        map.addAnnotation(start)

        if let endCoordinate {
            let end = MKPointAnnotation()
            end.coordinate = endCoordinate
            end.title = "Destination"
            end.subtitle = "End Location"
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
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard annotation is MKPointAnnotation else { return nil }

            let identifier = "TripPointLabel"
            let annotationView = (mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? TripPointAnnotationView)
                ?? TripPointAnnotationView(annotation: annotation, reuseIdentifier: identifier)

            annotationView.annotation = annotation
            annotationView.configure(
                title: (annotation.title ?? "")!,
                subtitle: (annotation.subtitle ?? "")!
            )
            return annotationView
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let route = overlay as? MKPolyline else { return MKOverlayRenderer(overlay: overlay) }
            let renderer = MKPolylineRenderer(polyline: route)
            renderer.strokeColor = UIColor(Color.theme.primaryGreen)
            renderer.lineWidth = 7
            return renderer
        }
    }
}

/// A permanent map label, unlike MapKit's standard callout which is visible only after tapping a pin.
private final class TripPointAnnotationView: MKAnnotationView {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let labelStack = UIStackView()
    private let pinImageView = UIImageView(image: UIImage(systemName: "mappin.circle.fill"))

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        frame = CGRect(x: 0, y: 0, width: 144, height: 74)
        centerOffset = CGPoint(x: 0, y: -37)
        canShowCallout = false

        titleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        titleLabel.textColor = UIColor(Color.theme.primaryGreen)
        titleLabel.textAlignment = .center

        subtitleLabel.font = .systemFont(ofSize: 11, weight: .regular)
        subtitleLabel.textColor = .label
        subtitleLabel.textAlignment = .center

        labelStack.axis = .vertical
        labelStack.alignment = .center
        labelStack.spacing = 2
        labelStack.addArrangedSubview(titleLabel)
        labelStack.addArrangedSubview(subtitleLabel)
        labelStack.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.92)
        labelStack.layer.cornerRadius = 14
        labelStack.layer.shadowColor = UIColor.black.cgColor
        labelStack.layer.shadowOpacity = 0.14
        labelStack.layer.shadowRadius = 5
        labelStack.layer.shadowOffset = CGSize(width: 0, height: 2)
        labelStack.isLayoutMarginsRelativeArrangement = true
        labelStack.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        labelStack.translatesAutoresizingMaskIntoConstraints = false

        pinImageView.tintColor = UIColor(Color.theme.primaryGreen)
        pinImageView.contentMode = .scaleAspectFit
        pinImageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(labelStack)
        addSubview(pinImageView)

        NSLayoutConstraint.activate([
            labelStack.topAnchor.constraint(equalTo: topAnchor),
            labelStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            labelStack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            labelStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            pinImageView.topAnchor.constraint(equalTo: labelStack.bottomAnchor, constant: 2),
            pinImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            pinImageView.widthAnchor.constraint(equalToConstant: 26),
            pinImageView.heightAnchor.constraint(equalToConstant: 26)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        subtitleLabel.text = nil
    }

    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
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
