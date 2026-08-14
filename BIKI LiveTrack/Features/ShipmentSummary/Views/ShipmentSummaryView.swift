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
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 28) {
                    shipmentHeader
                    
                    Text("Shipment Overview")
                        .font(.app.heading1)
                        .foregroundColor(Color.theme.textPrimary)
                    
                    HStack(alignment: .top, spacing: 18) {
                        SensorCardShipmentHistoryComponent(
                            title: "Temperature",
                            averageValue: viewModel.temperatureText(viewModel.averageTemperature),
                            minValue: viewModel.temperatureText(viewModel.minimumTemperature),
                            maxValue: viewModel.temperatureText(viewModel.maximumTemperature),
                            statusIcon: "checkmark.circle.fill",
                            statusText: viewModel.temperatureIsIdeal ? "Ideal" : "Warning",
                            statusColor: viewModel.temperatureIsIdeal ? Color.theme.primaryGreen : Color.theme.primaryYellow
                        )
                        
                        SensorCardShipmentHistoryComponent(
                            title: "Humidity",
                            averageValue: viewModel.humidityText(viewModel.averageHumidity),
                            minValue: viewModel.humidityText(viewModel.minimumHumidity),
                            maxValue: viewModel.humidityText(viewModel.maximumHumidity),
                            statusIcon: "exclamationmark.triangle.fill",
                            statusText: viewModel.humidityIsIdeal ? "Ideal" : "Warning",
                            statusColor: viewModel.humidityIsIdeal ? Color.theme.primaryGreen : Color.theme.primaryYellow
                        )
                        
                        Button {
                            isShowingTripDetails = true
                        } label: {
                            // Menggunakan LocationLabelComponent dengan AnyView
                            TripDurationCardComponent(
                                duration: viewModel.tripDuration,
                                origin: AnyView(LocationLabelComponent(latitude: viewModel.startCoordinate.latitude, longitude: viewModel.startCoordinate.longitude)),
                                destination: AnyView(
                                    Group {
                                        if let endCoord = viewModel.endCoordinate {
                                            LocationLabelComponent(latitude: endCoord.latitude, longitude: endCoord.longitude)
                                        } else {
                                            Text("In progress")
                                                .font(.app.body)
                                                .foregroundColor(Color.theme.textSecondary)
                                        }
                                    }
                                )
                            )
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity)
                    }
                    
                    HStack {
                        Text("Historical Log")
                            .font(.app.heading1)
                            .foregroundColor(Color.theme.textPrimary)
                        
                        Spacer()
                        
                        Picker("Historical log display", selection: $selectedLogDisplay) {
                            ForEach(HistoricalLogDisplay.allCases) { display in
                                Text(display.rawValue).tag(display)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 280)
                    }
                    
                }
                .padding(.horizontal, 32)
                .padding(.top, 26)
                
                ScrollView(showsIndicators: true) {
                    logContent
                        .padding(.horizontal, 32)
                        .padding(.bottom, 32)
                }
            VStack(alignment: .leading, spacing: 28) {
                shipmentHeader

                Text("Shipment Overview")
                    .font(.app.heading1)
                    .foregroundColor(Color.theme.textPrimary)

                HStack(alignment: .top, spacing: 18) {
                    SensorCardShipmentHistoryComponent(
                        title: "Temperature",
                        averageValue: viewModel.temperatureText(viewModel.averageTemperature),
                        minValue: viewModel.temperatureText(viewModel.minimumTemperature),
                        maxValue: viewModel.temperatureText(viewModel.maximumTemperature),
                        status: viewModel.temperatureIsIdeal ? .ideal : .warning
                    )

                    SensorCardShipmentHistoryComponent(
                        title: "Humidity",
                        averageValue: viewModel.humidityText(viewModel.averageHumidity),
                        minValue: viewModel.humidityText(viewModel.minimumHumidity),
                        maxValue: viewModel.humidityText(viewModel.maximumHumidity),
                        status: viewModel.humidityIsIdeal ? .ideal : .warning
                    )

                    Button {
                        isShowingTripDetails = true
                    } label: {
                        TripDurationCardComponent(
                            duration: viewModel.tripDuration,
                            origin: "Start location",
                            destination: "Destination"
                        )
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                }

                HStack {
                    Text("Historical Log")
                        .font(.app.heading1)
                        .foregroundColor(Color.theme.textPrimary)

                    Spacer()

                    Picker("Historical log display", selection: $viewModel.selectedLogDisplay) {
                        ForEach(HistoricalLogDisplay.allCases) { display in
                            Text(display.rawValue).tag(display)
                        } //test
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 280)
                }

            }
            .padding(.horizontal, 32)
            .padding(.top, 26)

            ScrollView(showsIndicators: true) {
                logContent
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
            }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
            .background(Color.theme.tertiaryGreen)
        }
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
                Text("#\(viewModel.shipment.id.uuidString.prefix(8).uppercased())")
                    .font(.system(size: 46, weight: .bold))
                Text(viewModel.shipmentIDText)
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(Color.theme.textPrimary)
                
                Spacer()
                
                exportMenu
            }
            
            HStack(alignment: .top, spacing: 56) {
                HeaderDetail(title: "Device Name", value: viewModel.shipment.device.name)
                HeaderDetail(title: "Plate Number", value: viewModel.shipment.truckPlateNumber)
                HeaderDetail(title: "Contact", value: "\(viewModel.shipment.driver.name) \(viewModel.shipment.driver.phoneNumber)")
                
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
        do {
            exportURL = try viewModel.generateCSVURL()
            isShowingShareSheet = true
        } catch {
            viewModel.errorMessage = "Could not create CSV: \(error.localizedDescription)"
        }
    }
    
    private func exportGraphPNG() {
        let graph = HistoricalLogGraphView(viewModel: viewModel)
            .frame(width: 1_200)
            .padding(32)
            .background(Color.theme.tertiaryGreen)
        
        let renderer = ImageRenderer(content: graph)
        renderer.scale = UIScreen.main.scale
        
        guard let pngData = renderer.uiImage?.pngData() else {
            viewModel.errorMessage = "Could not create graph image."
            return
        }
        
        let shipmentID = viewModel.shipment.id.uuidString.prefix(8).uppercased()
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("Shipment_\(shipmentID)_Historical_Graph.png")
        
        do {
            try pngData.write(to: url, options: [.atomic])
            exportURL = url
            isShowingShareSheet = true
        } catch {
            viewModel.errorMessage = "Could not save graph image: \(error.localizedDescription)"
        }
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

// Sample data used only by Xcode previews in this feature.
enum ShipmentSummaryPreviewData {
    static let startDate = Date(timeIntervalSince1970: 1_785_993_600)
    static let endDate = Date(timeIntervalSince1970: 1_786_050_900)

    static let shipment = Shipment(
        id: UUID(uuidString: "B1175000-0000-0000-0000-000000000000")!,
        device: Device(id: UUID(uuidString: "D1175000-0000-0000-0000-000000000000")!, name: "IoT_Testing01"),
        driver: Driver(id: UUID(uuidString: "A1175000-0000-0000-0000-000000000000")!, name: "Septa Bayu", phoneNumber: "0878 xxx xxx"),
        truckPlateNumber: "DK 8959 JKY",
        startDate: startDate,
        endDate: endDate,
        startLatitude: -6.3005,
        startLongitude: 106.6527,
        endLatitude: -7.0051,
        endLongitude: 110.4381
    )

    // Preview-only readings, sampled every 10 minutes to make the Swift Charts
    // line visible in Xcode Canvas. Production uses the real API sensor logs.
    static let sensorLogs: [SensorLog] = (0..<37).map { index in
        let minutes = Double(index * 10)
        let temperature = 9.5 + sin(Double(index) * 0.42) * 1.4
        let humidity = 86.5 + cos(Double(index) * 0.35) * 3.8
        let progress = Double(index) / 36
        let latitude = -6.3005 + ((-7.0051) - (-6.3005)) * progress
        let longitude = 106.6527 + (110.4381 - 106.6527) * progress
        return log(minutes: minutes, temperature: temperature, humidity: humidity, latitude: latitude, longitude: longitude)
    }

    private static func log(minutes: Double, temperature: Double, humidity: Double, latitude: Double, longitude: Double) -> SensorLog {
        SensorLog(
            id: UUID(),
            shipmentID: shipment.id,
            temperature: temperature,
            humidity: humidity,
            latitude: [latitude],
            longitude: [longitude],
            timestamps: startDate.addingTimeInterval(minutes * 60)
        )
    }
}

private final class ShipmentSummaryPreviewSensorLogRepository: SensorLogRepositoryProtocol {
    func fetchAllSensors() async throws -> [SensorLog] {
        ShipmentSummaryPreviewData.sensorLogs
    }

    func fetchSensors(byShipmentID shipmentID: String) async throws -> [SensorLog] {
        ShipmentSummaryPreviewData.sensorLogs
    }
}

#Preview("Shipment Summary — Landscape", traits: .landscapeLeft) {
    ShipmentSummaryView(
        shipment: ShipmentSummaryPreviewData.shipment,
        sensorLogRepository: ShipmentSummaryPreviewSensorLogRepository()
    )
}

