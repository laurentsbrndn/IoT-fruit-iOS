//
//  LiveShipmentView.swift
//  BIKI LiveTrack
//

import SwiftUI
import CoreLocation

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
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .top) {
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
                    .padding(.horizontal, 24)
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
                        
                        TimelineView(.periodic(from: .now, by: 1)) { context in
                            TripDurationCardComponent(
                                duration: viewModel.tripDuration(asOf: context.date),
                                origin: AnyView(
                                    LocationLabelComponent(
                                        latitude: viewModel.startCoordinate.latitude,
                                        longitude: viewModel.startCoordinate.longitude
                                    )
                                ),
                                destination: AnyView(
                                    Group {
                                        if let endCoord = viewModel.endCoordinate {
                                            LocationLabelComponent(
                                                latitude: endCoord.latitude,
                                                longitude: endCoord.longitude
                                            )
                                        } else {
                                            Text("In progress")
                                                .font(.app.body)
                                                .foregroundColor(Color.theme.textSecondary)
                                        }
                                    }
                                )
                            )
                        }
                    }
                    .padding(.horizontal, 24)
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
                            ScrollView(.vertical, showsIndicators: true) {
                                VStack(spacing: 12) {
                                    ForEach(viewModel.alerts, id: \.id) { alert in
                                        AlertBannerComponent(
                                            alertType: alert.alertType,
                                            timeString: viewModel.formatTimeAgo(from: alert.timestamps)
                                        )
                                    }
                                }
                                .padding(.trailing, 4)
                            }
                            .frame(maxHeight: 260)
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(20)
                    .padding(.horizontal, 24)
                    
                }
                .frame(width: windowWidth, alignment: .leading)
                .padding(.vertical, 16)
            }
        }
        .background(Color.theme.tertiaryGreen.opacity(0.3).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await viewModel.loadLiveShipmentData()
        }
        .task {
            await viewModel.loadLiveShipmentData()
        }
    }
}

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
                .font(.app.bodyBold)
                .foregroundColor(Color.theme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
