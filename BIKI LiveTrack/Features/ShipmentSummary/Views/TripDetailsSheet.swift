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
