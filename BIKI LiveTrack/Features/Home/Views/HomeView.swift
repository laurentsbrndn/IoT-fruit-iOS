//
//  HomeView.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 06/08/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var maxScreenWidth: CGFloat = 0
    
    private let autoRefreshInterval: UInt64 = 60
    
    var body: some View {
        let dynamicLiveColumnWidth = max(320, (windowWidth - 80) / 3)
        let dynamicHistoryCardWidth = max(360, windowWidth * 0.38)
        
        VStack(alignment: .leading, spacing: 32) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recently Delivered (\(viewModel.deliveredShipments.count))")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color.theme.textPrimary)
                        .padding(.horizontal, 24)
                    
                    if viewModel.isLoading && viewModel.deliveredShipments.isEmpty {
                        ProgressView()
                            .padding(.top, 20)
                            .padding(.horizontal, 24)
                    } else if viewModel.deliveredShipments.isEmpty {
                        Text("No delivered shipments yet.")
                            .foregroundColor(Color.theme.textSecondary)
                            .padding(.horizontal, 24)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(viewModel.deliveredShipments) { shipment in
                                    NavigationLink(destination: ShipmentSummaryView(shipment: shipment)) {
                                        ShipmentHistoryInfoCardComponent(
                                            shipmentID: "#\(shipment.id.uuidString.prefix(8).uppercased())",
                                            statusText: "Delivered",
                                            statusDate: formatShipmentDate(shipment.endDate),
                                            latitude: shipment.endLatitude ?? 0.0,
                                            longitude: shipment.endLongitude ?? 0.0,
                                            driverName: shipment.driver.name,
                                            driverContact: shipment.driver.phoneNumber
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .frame(width: dynamicHistoryCardWidth)
                                    
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                }
                .padding(.top, 16)
                VStack(alignment: .leading, spacing: 16) {
                    Text("Currently Live")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color.theme.textPrimary)
                        .padding(.horizontal, 24)
                    
                    if viewModel.isLoading && viewModel.activeShipments.isEmpty {
                        ProgressView()
                            .padding(.top, 20)
                            .padding(.horizontal, 24)
                    } else if viewModel.activeShipments.isEmpty {
                        Text("No active shipments at the moment.")
                            .foregroundColor(Color.theme.textSecondary)
                            .padding(.horizontal, 24)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .top, spacing: 16) {
                                
                                liveColumnView(
                                    title: "All systems in ideal conditions",
                                    dotColor: Color.theme.primaryGreen,
                                    count: idealShipments.count,
                                    shipments: idealShipments,
                                    columnWidth: dynamicLiveColumnWidth
                                )
                                
                                liveColumnView(
                                    title: "Need attentions",
                                    dotColor: Color.theme.primaryYellow,
                                    count: warningShipments.count,
                                    shipments: warningShipments,
                                    columnWidth: dynamicLiveColumnWidth
                                )
                                
                                liveColumnView(
                                    title: "Devices are not connected",
                                    dotColor: Color.theme.primaryRed,
                                    count: offlineShipments.count,
                                    shipments: offlineShipments,
                                    isCountHighlighted: true,
                                    columnWidth: dynamicLiveColumnWidth
                                )
                            }
                            .padding(.horizontal, 24)
                            .frame(maxHeight: .infinity)
                        }
                    }
                }
                .frame(maxHeight: .infinity)
            }
        .padding(.bottom, 24)
        .background(Color.clear)
        .refreshable {
            await viewModel.loadHomeData(showLoading: false)
        }
        .task {
            await viewModel.loadHomeData()
            
            while !Task.isCancelled {
                do {
                    try await Task.sleep(nanoseconds: autoRefreshInterval * 1_000_000_000)
                } catch {
                    break
                }
                
                guard !Task.isCancelled else { break }
                await viewModel.loadHomeData(showLoading: false)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    print("Tombol Plus ditekan dari HomeView")
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(width: 36, height: 36)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
            }
        }
    }
    
    @ViewBuilder
    private func liveColumnView(title: String, dotColor: Color, count: Int, shipments: [Shipment], isCountHighlighted: Bool = false, columnWidth: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Circle()
                    .fill(dotColor)
                    .frame(width: 10, height: 10)
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(count)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isCountHighlighted ? dotColor : .secondary)
            }
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(shipments) { shipment in
                        NavigationLink(destination: LiveShipmentView(shipment: shipment)) {
                            ShipmentLiveInfoCardComponent(
                                shipmentID: "#\(shipment.id.uuidString.prefix(8).uppercased())",
                                status: viewModel.shipmentStatuses[shipment.id] ?? .ideal,
                                latitude: shipment.endLatitude ?? 0.0,
                                longitude: shipment.endLongitude ?? 0.0,
                                driverName: shipment.driver.name,
                                driverContact: shipment.driver.phoneNumber
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.bottom, 16)
            }
        }
        .padding(16)
        .background(Color.theme.FrameCard)
        .cornerRadius(16)
        .frame(width: columnWidth)
        .frame(maxHeight: .infinity)
    }
    
    private var idealShipments: [Shipment] {
        viewModel.activeShipments.filter { viewModel.shipmentStatuses[$0.id] == .ideal }
    }
    
    private var warningShipments: [Shipment] {
        viewModel.activeShipments.filter { String(describing: viewModel.shipmentStatuses[$0.id]).lowercased().contains("warning") }
    }
    
    private var offlineShipments: [Shipment] {
        viewModel.activeShipments.filter { String(describing: viewModel.shipmentStatuses[$0.id]).lowercased().contains("offline") }
    }
    
    private func formatShipmentDate(_ date: Date?) -> String {
        guard let date else {
            return "—"
        }
        
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            let time = date.formatted(
                .dateTime
                    .hour(.twoDigits(amPM: .omitted))
                    .minute(.twoDigits)
            )
            
            return "Today, \(time)"
        }
        
        return date.formatted(
            .dateTime
                .day(.twoDigits)
                .month(.abbreviated)
                .hour(.twoDigits(amPM: .omitted))
                .minute(.twoDigits)
        )
    }
}

#Preview(traits: .landscapeLeft) {
    NavigationStack {
        HomeView()
    }
}
