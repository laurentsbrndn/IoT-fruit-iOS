//
//  LiveShipmentView.swift
//  BIKI LiveTrack
//
//  Created by Grace Frendy on 13/08/26.
//


import SwiftUI

struct LiveShipmentView: View {
    @StateObject private var viewModel: LiveShipmentViewModel
    
    init(
        shipment: Shipment,
        sensorLogRepository: SensorLogRepositoryProtocol = SensorLogRepository(),
        alertLogRepository: AlertLogRepositoryProtocol = AlertLogRepository()
    ) {
        _viewModel = StateObject(
            wrappedValue: LiveShipmentViewModel(
                shipment: shipment,
                sensorLogRepository: sensorLogRepository,
                alertLogRepository: alertLogRepository
            )
        )
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                
                // MARK: - Header Status & Title
                VStack(alignment: .leading, spacing: 16) {
                    HStack (alignment: .top) {
                        Text(viewModel.shipmentIDText)
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(Color.theme.textPrimary)
                        
                        Spacer()
                        
                        Text("Last updated \(viewModel.lastUpdatedTimeText)")
                            .font(.app.title2)
                            .foregroundColor(Color.theme.primaryGreen)
                        
                      
                    }
                    
                    HStack(alignment: .top) {
                        HeaderDetail(title: "Device Name", value: viewModel.deviceIDText)
                        HeaderDetail(title: "Plate Number", value: viewModel.plateNumberText)
                        HeaderDetail(title: "Contact", value: viewModel.contactText)
                        HeaderDetail(title: "Address", value: viewModel.destinationText)
                    }
                }
                .padding(.horizontal, 24)
                
                // MARK: - Sensor Cards & Trip Duration Row
                HStack(spacing: 16) {
                    SensorCardActiveShipmentComponent(
                        title: "Temperature",
                        value: viewModel.temperatureValueText,
                        status: viewModel.temperatureStatus,
                        progress: viewModel.temperatureProgress
                    )
                    
                    SensorCardActiveShipmentComponent(
                        title: "Humidity",
                        value: viewModel.humidityValueText,
                        status: viewModel.humidityStatus,
                        progress: viewModel.humidityProgress
                    )
                    
                    TripDurationCardComponent(
                        duration: viewModel.tripDuration,
                        origin: AnyView(Text(viewModel.originText)),
                        destination: AnyView(Text(viewModel.destinationText))
                    )
                }
                .padding(.horizontal, 24)
                
                // MARK: - Alerts Section Container
                VStack(alignment: .leading, spacing: 16) {
                    Text("Alerts")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.theme.textPrimary)
                    
                    if viewModel.isLoading && viewModel.alerts.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 20)
                    } else if viewModel.alerts.isEmpty {
                        Text("No alerts recorded.")
                            .font(.system(size: 16))
                            .foregroundColor(Color.theme.textSecondary)
                            .padding(.vertical, 10)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(viewModel.alerts, id: \.id) { alert in
                                AlertBannerComponent(
                                    alertType: alert.alertType,
                                    timeString: viewModel.formatTimeAgo(from: alert.timestamps)
                                )
                            }
                        }
                    }
                }
                .padding(24)
                .background(Color.white)
                .cornerRadius(20)
                .padding(.horizontal, 24)
            }
            .padding(.vertical, 16)
        }
        .background(Color.theme.tertiaryGreen.opacity(0.3).ignoresSafeArea())
        .refreshable {
            await viewModel.loadLiveShipmentData()
        }
        .task {
            await viewModel.loadLiveShipmentData()
        }
    }
}

// MARK: - Subview Privat HeaderDetail

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

// MARK: - Preview Mock Data & Classes

private enum LiveShipmentPreviewData {
    static let startDate = Date()
    
    static let shipment = Shipment(
        id: UUID(uuidString: "B189300A-0000-4000-8000-00805F9B34FB")!,
        device: Device(id: UUID(), name: "IoT_Testing01"),
        driver: Driver(id: UUID(), name: "Septa Bayu", phoneNumber: "0878 xxx xxx"),
        truckPlateNumber: "DK 8959 JKY",
        startDate: startDate,
        endDate: nil,
        startLatitude: -6.3005,
        startLongitude: 106.6527,
        endLatitude: -7.0051,
        endLongitude: 110.4381
    )

    static let sensorLogs: [SensorLog] = [
        SensorLog(
            id: UUID(),
            temperature: 10.0,
            humidity: 88.0,
            latitude: [-6.3005],
            longitude: [106.6527],
            timestamps: Date(),
            shipment: SensorLog.ShipmentReference(id: shipment.id)
        )
    ]
}

private final class LiveShipmentPreviewSensorLogRepository: SensorLogRepositoryProtocol {
    func fetchAllSensors() async throws -> [SensorLog] {
        LiveShipmentPreviewData.sensorLogs
    }

    func fetchSensors(byShipmentID shipmentID: String) async throws -> [SensorLog] {
        LiveShipmentPreviewData.sensorLogs
    }
}

private final class LiveShipmentPreviewAlertLogRepository: AlertLogRepositoryProtocol {
    func fetchAllAlerts() async throws -> [AlertLog] {
        mockAlerts
    }

    func fetchAlerts(byShipmentID shipmentID: String) async throws -> [AlertLog] {
        mockAlerts
    }

    private var mockAlerts: [AlertLog] {
        guard let sensorLog = LiveShipmentPreviewData.sensorLogs.first else { return [] }
        
        return [
            AlertLog(
                id: UUID(),
                alertType: .highTemperature,
                shipmentID: LiveShipmentPreviewData.shipment.id,
                sensorLogID: sensorLog.id,
                timestamps: Date().addingTimeInterval(-600)
            ),
            AlertLog(
                id: UUID(),
                alertType: .lowHumidity,
                shipmentID: LiveShipmentPreviewData.shipment.id,
                sensorLogID: sensorLog.id,
                timestamps: Date().addingTimeInterval(-3600)
            ),
            AlertLog(
                id: UUID(),
                alertType: .connectionBack,
                shipmentID: LiveShipmentPreviewData.shipment.id,
                sensorLogID: sensorLog.id,
                timestamps: Date().addingTimeInterval(-3600)
                ),
            AlertLog(
                id: UUID(),
                alertType: .lostConnection,
                shipmentID: LiveShipmentPreviewData.shipment.id,
                sensorLogID: sensorLog.id,
                timestamps: Date().addingTimeInterval(-3600)
                )
        ]
    }
}

#Preview("Live Shipment — Landscape", traits: .landscapeLeft) {
    NavigationStack {
        LiveShipmentView(
            shipment: LiveShipmentPreviewData.shipment,
            sensorLogRepository: LiveShipmentPreviewSensorLogRepository(),
            alertLogRepository: LiveShipmentPreviewAlertLogRepository()
        )
    }
}

