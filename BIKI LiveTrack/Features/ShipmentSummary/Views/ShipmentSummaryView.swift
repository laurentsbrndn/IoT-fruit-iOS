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

struct ExportItem: Identifiable {
    let id = UUID()
    let url: URL
}

struct ShipmentSummaryView: View {
    @StateObject private var viewModel: ShipmentSummaryViewModel
    @State private var selectedLogDisplay: HistoricalLogDisplay = .graph
    @State private var isShowingTripDetails = false
    @State private var exportItem: ExportItem?
    @State private var isShowingStartDateAdjustment = false
    @State private var isShowingEndDateAdjustment = false
    
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
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
            
            // Only the content below the shipment information scrolls.
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 24) {
                    // MARK: - Shipment Overview
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Shipment Overview")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color.theme.textPrimary)
                        
                        HStack(alignment: .top, spacing: 22) {
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
                                                Text("Destination unavailable")
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
                                .font(.system(size: 24, weight: .bold))
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
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.theme.tertiaryGreen
                .ignoresSafeArea()
        )
        .task {
            await viewModel.loadSummaryData()
        }

        // Opens the map and read-only trip details.
        .sheet(isPresented: $isShowingTripDetails) {
            TripDetailsSheetView(viewModel: viewModel)
        }

        // Opens when "Adjust Start Date & Time" is selected.
        .sheet(isPresented: $isShowingStartDateAdjustment) {
            ShipmentDateTimeAdjustmentSheet(
                viewModel: viewModel,
                editType: .start
            )
        }

        .sheet(isPresented: $isShowingEndDateAdjustment) {
            ShipmentDateTimeAdjustmentSheet(
                viewModel: viewModel,
                editType: .end
            )
        }

        .sheet(item: $exportItem) { item in
            ActivitySheet(activityItems: [item.url])
        }
    }
    
    private var shipmentHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                Text(viewModel.shipmentIDText)
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(Color.theme.textPrimary)
                
                Spacer()
                
                exportMenu
            }
            
            HStack(alignment: .top, spacing: 8) {
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
        ShipmentSummaryMenuComponent(
            onExportCSV: exportCSV,
            onExportGraphPNG: exportGraphPNG,
            onAdjustStartDateTime: {
                isShowingStartDateAdjustment = true
            },
            onAdjustEndDateTime: {
                isShowingEndDateAdjustment = true
            }
        )
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
        
        exportItem = ExportItem(url: url)
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
                .foregroundStyle(.secondary)
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
