//
//  ShipmentSummaryView.swift
//  BIKI LiveTrack
//
//  Created by Joana Mardas on 13/08/26.
//

import SwiftUI
import UIKit
import CoreLocation

enum HistoricalLogDisplay: String, CaseIterable, Identifiable {
    case graph = "Graph"
    case table = "Table"
    
    var id: Self { self }
}

struct ShipmentSummaryView: View {
    @StateObject private var viewModel: ShipmentSummaryViewModel
    @State private var selectedLogDisplay: HistoricalLogDisplay = .graph
    @State private var isShowingTripDetails = false
    @State private var exportURL: URL?
    @State private var isShowingShareSheet = false
    
    init(
        shipment: Shipment,
        sensorLogRepository: SensorLogRepositoryProtocol = SensorLogRepository()
    ) {
        _viewModel = StateObject(
            wrappedValue: ShipmentSummaryViewModel(
                shipment: shipment,
                sensorLogRepository: sensorLogRepository
            )
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // This header stays fixed and does not scroll.
            shipmentHeader
                .padding(.horizontal, 32)
                .padding(.top, 26)
                .padding(.bottom, 24)

            // Only the content below the shipment information scrolls.
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 32) {
                    // MARK: - Shipment Overview

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Shipment Overview")
                            .font(.app.heading1)
                            .foregroundColor(Color.theme.textPrimary)

                        HStack(alignment: .top, spacing: 18) {
                            SensorCardShipmentHistoryComponent(
                                title: "Temperature",
                                averageValue: viewModel.temperatureAverageText,
                                minValue: viewModel.temperatureMinimumText,
                                maxValue: viewModel.temperatureMaximumText,
                                status: viewModel.temperatureStatus
                            )

                            SensorCardShipmentHistoryComponent(
                                title: "Humidity",
                                averageValue: viewModel.humidityAverageText,
                                minValue: viewModel.humidityMinimumText,
                                maxValue: viewModel.humidityMaximumText,
                                status: viewModel.humidityStatus
                            )

                            Button {
                                isShowingTripDetails = true
                            } label: {
                                TripDurationCardComponent(
                                    duration: viewModel.tripDuration,
                                    origin: AnyView(
                                        LocationLabelComponent(
                                            latitude:
                                                viewModel.startCoordinate.latitude,
                                            longitude:
                                                viewModel.startCoordinate.longitude
                                        )
                                    ),
                                    destination: AnyView(
                                        Group {
                                            if let endCoordinate =
                                                viewModel.endCoordinate {

                                                LocationLabelComponent(
                                                    latitude:
                                                        endCoordinate.latitude,
                                                    longitude:
                                                        endCoordinate.longitude
                                                )
                                            } else {
                                                Text("In progress")
                                                    .font(.app.body)
                                                    .foregroundColor(
                                                        Color.theme.textSecondary
                                                    )
                                            }
                                        }
                                    )
                                )
                            }
                            .buttonStyle(.plain)
                            .frame(maxWidth: .infinity)
                        }
                    }

                    // MARK: - Historical Log

                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Historical Log")
                                .font(.app.heading1)
                                .foregroundColor(Color.theme.textPrimary)

                            Spacer()

                            Picker(
                                "Historical log display",
                                selection: $selectedLogDisplay
                            ) {
                                ForEach(
                                    HistoricalLogDisplay.allCases
                                ) { display in
                                    Text(display.rawValue)
                                        .tag(display)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 280)
                        }

                        logContent
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.tertiaryGreen)
        .task {
            await viewModel.loadSummaryData()
        }
        .sheet(isPresented: $isShowingTripDetails) {
            TripDetailsSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $isShowingShareSheet) {
            if let exportURL {
                ActivitySheet(activityItems: [exportURL])
            }
        }
    }
    
    private var shipmentHeader: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top) {
                Text(viewModel.shipmentIDText)
                    .font(.system(size: 46, weight: .bold))
                    .foregroundColor(Color.theme.textPrimary)
                
                Spacer()
                
                exportMenu
            }
            
            HStack(alignment: .top, spacing: 56) {
                HeaderDetail(
                    title: "Device Name",
                    value: viewModel.deviceNameText
                )
                HeaderDetail(
                    title: "Plate Number",
                    value: viewModel.plateNumberText
                )
                HeaderDetail(
                    title: "Contact",
                    value: viewModel.contactText
                )
    
                if let endCoord = viewModel.endCoordinate {
                    HeaderLocationDetail(
                        title: "Address",
                        latitude: endCoord.latitude,
                        longitude: endCoord.longitude
                    )
                    .foregroundColor(.black)
                    .bold()
                } else {
                    HeaderDetail(title: "Address", value: "In progress")
                }
            }
        }
    }
    
    private var exportMenu: some View {
        Menu {
            Button {
                exportCSV()
            } label: {
                Label("Export Data\nAs CSV", systemImage: "square.and.arrow.up")
            }
            
            Button {
                exportGraphPNG()
            } label: {
                Label("Export Graph\nAs PNG", systemImage: "square.and.arrow.up")
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 21, weight: .bold))
                .foregroundColor(Color.theme.textPrimary)
                .frame(width: 48, height: 48)
                .background(.ultraThinMaterial, in: Circle())
        }
        .accessibilityLabel("Export options")
    }
    
    private func exportCSV() {
        presentExport(
            viewModel.prepareCSVExport()
        )
    }

    private func exportGraphPNG() {
        // ImageRenderer stays in the View because it renders SwiftUI.
        let graph = HistoricalLogGraphView(
            viewModel: viewModel
        )
        .frame(width: 1_200)
        .padding(32)
        .background(Color.theme.tertiaryGreen)

        let renderer = ImageRenderer(
            content: graph
        )

        renderer.scale = UIScreen.main.scale

        let pngData =
            renderer.uiImage?.pngData()

        presentExport(
            viewModel.prepareGraphPNGExport(
                from: pngData
            )
        )
    }

    private func presentExport(
        _ url: URL?
    ) {
        guard let url else {
            return
        }

        exportURL = url
        isShowingShareSheet = true
    }
    
    @ViewBuilder private var logContent: some View {
        if viewModel.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, minHeight: 280)
        } else if let errorMessage = viewModel.errorMessage {
            ContentUnavailableView("Could not load sensor history", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
                .frame(maxWidth: .infinity, minHeight: 280)
        } else if viewModel.sensorLogs.isEmpty {
            ContentUnavailableView("No historical readings", systemImage: "chart.xyaxis.line")
                .frame(maxWidth: .infinity, minHeight: 280)
        } else if selectedLogDisplay == .graph {
            HistoricalLogGraphView(viewModel: viewModel)
        } else {
            HistoricalLogTableView(viewModel: viewModel)
        }
    }
}

// MARK: - Header Components

private struct HeaderDetail: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.app.body)
                .foregroundColor(Color.theme.textSecondary)
            Text(value)
                .font(.app.bodyBold)
                .foregroundColor(Color.theme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Header detail khusus untuk me-render LocationLabelComponent
private struct HeaderLocationDetail: View {
    let title: String
    let latitude: Double
    let longitude: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.app.body)
                .foregroundColor(Color.theme.textSecondary)
            
            LocationLabelComponent(latitude: latitude, longitude: longitude)
                // Styling dibuat semirip mungkin dengan teks "value" di HeaderDetail
                .font(.app.bodyBold)
                .foregroundColor(Color.theme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ActivitySheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#if DEBUG
#Preview(
    "Shipment Summary — Landscape",
    traits: .landscapeLeft
) {
    ShipmentSummaryDatabasePreview()
}

@MainActor
private struct ShipmentSummaryDatabasePreview: View {
    @StateObject private var previewLoader =
        HistoricalLogGraphPreviewViewModel()

    var body: some View {
        Group {
            if let summaryViewModel =
                previewLoader.summaryViewModel {

                ShipmentSummaryView(
                    shipment: summaryViewModel.shipment
                )

            } else if let errorMessage =
                previewLoader.errorMessage {

                ContentUnavailableView(
                    "Could not load preview",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )

            } else {
                ProgressView("Loading shipment data…")
            }
        }
        .task {
            await previewLoader.load()
        }
    }
}
#endif
