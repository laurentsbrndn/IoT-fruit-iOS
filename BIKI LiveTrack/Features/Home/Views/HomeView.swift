//
//  HomeView.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 06/08/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    let gridColumns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 48) {
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Currently Live")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color.theme.textPrimary)
                    
                    if viewModel.isLoading && viewModel.activeShipments.isEmpty {
                        ProgressView()
                            .padding(.top, 20)
                    } else if viewModel.activeShipments.isEmpty {
                        Text("No active shipments at the moment.")
                            .foregroundColor(Color.theme.textSecondary)
                    } else {
                        LazyVGrid(columns: gridColumns, spacing: 16) {
                            ForEach(viewModel.activeShipments) { shipment in
                                ShipmentInfoCardComponent(
                                    shipmentID: "#\(shipment.id.uuidString.prefix(8).uppercased())",
                                    statusIcon: "truck.box.fill",
                                    statusText: "In Transit",
                                    statusColor: Color.theme.primary,
                                    latitude: shipment.endLatitude ?? 0.0,
                                    longitude: shipment.endLongitude ?? 0.0,
                                    driverName: "Plat: \(shipment.truckPlateNumber)",
                                    driverContact: "ID: \(shipment.driverID.uuidString.prefix(8))"
                                )
                            }
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Recently Delivered")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color.theme.textPrimary)
                    
                    if viewModel.isLoading && viewModel.deliveredShipments.isEmpty {
                        ProgressView()
                            .padding(.top, 20)
                    } else if viewModel.deliveredShipments.isEmpty {
                        Text("No delivered shipments yet.")
                            .foregroundColor(Color.theme.textSecondary)
                    } else {
                        LazyVGrid(columns: gridColumns, spacing: 16) {
                            ForEach(viewModel.deliveredShipments) { shipment in
                                ShipmentInfoCardComponent(
                                    shipmentID: "#\(shipment.id.uuidString.prefix(8).uppercased())",
                                    statusIcon: "checkmark.seal.fill",
                                    statusText: "Delivered",
                                    statusColor: Color.theme.accent,
                                    latitude: shipment.endLatitude ?? 0.0,
                                    longitude: shipment.endLongitude ?? 0.0,
                                    driverName: "Plat: \(shipment.truckPlateNumber)",
                                    driverContact: "ID: \(shipment.driverID.uuidString.prefix(8))"
                                )
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.clear)
        .refreshable {
            await viewModel.loadHomeData()
        }
        .task {
            await viewModel.loadHomeData()
        }
    }
}

#Preview(traits: .landscapeLeft) {
    HomeView()
}
