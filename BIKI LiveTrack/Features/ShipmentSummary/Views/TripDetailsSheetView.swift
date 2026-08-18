import SwiftUI
import MapKit

struct TripDetailsSheet: View {
    @StateObject private var viewModel: TripDetailsSheetViewModel
    @Environment(\.dismiss) private var dismiss

    // This keeps ShipmentSummaryView.swift unchanged.
    init(viewModel: ShipmentSummaryViewModel) {
        _viewModel = StateObject(
            wrappedValue: TripDetailsSheetViewModel(
                shipment: viewModel.shipment,
                locationLogs: viewModel.locationLogs
            )
        )
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                header

                ZStack(alignment: .top) {
                    RouteMapView(
                        startCoordinate: viewModel.startCoordinate,
                        endCoordinate: viewModel.endCoordinate,
                        routeCoordinates: viewModel.routeCoordinates,
                        startLocationName: viewModel.startLocationName,
                        endLocationName: viewModel.endLocationName,
                        endPointTitle: "Destination"
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 16,
                            style: .continuous
                        )
                    )

                    durationCard
                        .padding(.top, 18)
                }
                .frame(minHeight: 350)

                HStack(alignment: .top, spacing: 18) {
                    LocationSummaryCard(
                        title: "Start Location",
                        date: viewModel.startDate,
                        locationName: viewModel.startLocationName
                    )

                    LocationSummaryCard(
                        title: "End Location",
                        date: viewModel.endDate,
                        locationName: viewModel.endLocationName
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .presentationDetents([.fraction(0.85)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
        .task {
            await viewModel.loadLocationNames()
        }
    }

    private var header: some View {
        HStack {
            Spacer()

            Text("Trip Details")
                .font(.app.bodyBold)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .overlay(alignment: .trailing) {
            Button("Close", systemImage: "xmark") {
                dismiss()
            }
            .labelStyle(.iconOnly)
            .foregroundStyle(.secondary)
            .accessibilityLabel("Close trip details")
        }
        .padding(.top, 24)
    }

    private var durationCard: some View {
        VStack(spacing: 4) {
            Text("Trip Duration")
                .font(.system(size: 20))

            Text(viewModel.tripDuration)
                .font(.system(size: 34))
                .monospacedDigit()
        }
        .frame(width: 214, height: 92)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
        .shadow(color: .black.opacity(0.1), radius: 4, y: 4)
    }
}

private struct LocationSummaryCard: View {
    let title: String
    let date: Date
    let locationName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.theme.primaryGreen)

            HStack(alignment: .top, spacing: 16) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.theme.primaryGreen)

                Text(date.toReadableString())
                    .font(.app.body)
                    .foregroundStyle(Color.theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(alignment: .top, spacing: 16) {
                Image(systemName: "mappin")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.theme.primaryGreen)

                Text(locationName)
                    .font(.app.body)
                    .foregroundStyle(Color.theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(
            maxWidth: .infinity,
            minHeight: 160,
            alignment: .leading
        )
        .padding(24)
        .background(Color.white.opacity(0.8))
        .clipShape(
            RoundedRectangle(
                cornerRadius: 15,
                style: .continuous
            )
        )
        .shadow(
            color: .black.opacity(0.1),
            radius: 4,
            y: 4
        )
    }
}

struct RouteMapView: UIViewRepresentable {
    let startCoordinate: CLLocationCoordinate2D
    let endCoordinate: CLLocationCoordinate2D?
    let routeCoordinates: [CLLocationCoordinate2D]
    let startLocationName: String
    let endLocationName: String
    let endPointTitle: String

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.isRotateEnabled = false
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        map.removeAnnotations(map.annotations)
        map.removeOverlays(map.overlays)

        map.addAnnotation(
            TripPointAnnotation(
                coordinate: startCoordinate,
                title: "Start Point",
                locationName: startLocationName
            )
        )

        if let endCoordinate {
            map.addAnnotation(
                TripPointAnnotation(
                    coordinate: endCoordinate,
                    title: endPointTitle,
                    locationName: endLocationName
                )
            )
        }

        if routeCoordinates.count > 1 {
            let route = MKPolyline(
                coordinates: routeCoordinates,
                count: routeCoordinates.count
            )

            map.addOverlay(route)

            map.setVisibleMapRect(
                route.boundingMapRect,
                edgePadding: UIEdgeInsets(
                    top: 80,
                    left: 70,
                    bottom: 70,
                    right: 70
                ),
                animated: false
            )
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(
            _ mapView: MKMapView,
            viewFor annotation: MKAnnotation
        ) -> MKAnnotationView? {
            guard let tripPoint = annotation as? TripPointAnnotation else {
                return nil
            }

            let identifier = "TripPointLabel"

            let view = (
                mapView.dequeueReusableAnnotationView(
                    withIdentifier: identifier
                ) as? TripPointAnnotationView
            ) ?? TripPointAnnotationView(
                annotation: tripPoint,
                reuseIdentifier: identifier
            )

            view.annotation = tripPoint
            view.configure(
                title: tripPoint.labelTitle,
                locationName: tripPoint.locationName
            )

            return view
        }

        func mapView(
            _ mapView: MKMapView,
            rendererFor overlay: MKOverlay
        ) -> MKOverlayRenderer {
            guard let route = overlay as? MKPolyline else {
                return MKOverlayRenderer(overlay: overlay)
            }

            let renderer = MKPolylineRenderer(polyline: route)
            renderer.strokeColor = UIColor(Color.theme.primaryGreen)
            renderer.lineWidth = 7
            return renderer
        }
    }
}

private final class TripPointAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let labelTitle: String
    let locationName: String

    var title: String? {
        labelTitle
    }

    init(
        coordinate: CLLocationCoordinate2D,
        title: String,
        locationName: String
    ) {
        self.coordinate = coordinate
        self.labelTitle = title
        self.locationName = locationName
    }
}

private final class TripPointAnnotationView: MKAnnotationView {
    private let titleLabel = UILabel()
    private let locationLabel = UILabel()
    private let labelStack = UIStackView()
    private let pinImageView = UIImageView(
        image: UIImage(systemName: "mappin.circle.fill")
    )

    override init(
        annotation: MKAnnotation?,
        reuseIdentifier: String?
    ) {
        super.init(
            annotation: annotation,
            reuseIdentifier: reuseIdentifier
        )

        frame = CGRect(
            x: 0,
            y: 0,
            width: 180,
            height: 92
        )

        // The final offset is calculated in layoutSubviews
        // so the route coordinate sits at the SF Symbol's center.
        centerOffset = .zero

        canShowCallout = false

        titleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        titleLabel.textColor = UIColor(Color.theme.primaryGreen)
        titleLabel.textAlignment = .center

        locationLabel.font = .systemFont(ofSize: 11)
        locationLabel.textColor = .label
        locationLabel.numberOfLines = 2
        locationLabel.textAlignment = .center
        locationLabel.lineBreakMode = .byWordWrapping

        labelStack.axis = .vertical
        labelStack.alignment = .center
        labelStack.spacing = 2
        labelStack.isLayoutMarginsRelativeArrangement = true
        labelStack.layoutMargins = UIEdgeInsets(
            top: 8,
            left: 12,
            bottom: 8,
            right: 12
        )
        labelStack.backgroundColor = UIColor.systemBackground
            .withAlphaComponent(0.92)
        labelStack.layer.cornerRadius = 14
        labelStack.layer.shadowColor = UIColor.black.cgColor
        labelStack.layer.shadowOpacity = 0.14
        labelStack.layer.shadowRadius = 5
        labelStack.layer.shadowOffset = CGSize(width: 0, height: 2)
        labelStack.translatesAutoresizingMaskIntoConstraints = false
        labelStack.addArrangedSubview(titleLabel)
        labelStack.addArrangedSubview(locationLabel)

        // Keeps a standard red/pink-like map pin while using an SF Symbol.
        pinImageView.tintColor =
            UIColor(Color.theme.primaryGreen)
        pinImageView.contentMode = .scaleAspectFit
        pinImageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(labelStack)
        addSubview(pinImageView)

        NSLayoutConstraint.activate([
            labelStack.topAnchor.constraint(
                equalTo: topAnchor
            ),

            labelStack.centerXAnchor.constraint(
                equalTo: centerXAnchor
            ),

            labelStack.widthAnchor.constraint(
                equalToConstant: 160
            ),

            pinImageView.topAnchor.constraint(
                equalTo: labelStack.bottomAnchor,
                constant: 2
            ),

            pinImageView.centerXAnchor.constraint(
                equalTo: centerXAnchor
            ),

            pinImageView.widthAnchor.constraint(
                equalToConstant: 26
            ),

            pinImageView.heightAnchor.constraint(
                equalToConstant: 26
            )
        ])
    }

    // MARK: - Route Endpoint Alignment

    override func layoutSubviews() {
        super.layoutSubviews()

        // pinImageView.frame.midY is the visible symbol's
        // vertical position inside the complete annotation.
        //
        // This offset places the map coordinate directly
        // in the center of the SF Symbol. The route line
        // therefore finishes behind and touches the symbol.
        let symbolCenterOffset =
            bounds.midY - pinImageView.frame.midY

        let updatedOffset = CGPoint(
            x: 0,
            y: symbolCenterOffset
        )

        if centerOffset != updatedOffset {
            centerOffset = updatedOffset
        }
    }

    required init?(coder: NSCoder) {
        fatalError(
            "init(coder:) has not been implemented"
        )
    }

    func configure(
        title: String,
        locationName: String
    ) {
        titleLabel.text = title
        locationLabel.text = locationName

        let symbolName: String

        if title == "Start Point" {
            symbolName = "mappin.circle.fill"
        } else {
            symbolName = "truck.box.fill"
        }

        pinImageView.image = UIImage(
            systemName: symbolName
        )

        pinImageView.tintColor =
            UIColor(Color.theme.primaryGreen)
    }
}

