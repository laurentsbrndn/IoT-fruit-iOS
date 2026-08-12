//
//  ShipmentHistoryView.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 11/08/26.
//

import SwiftUI

struct ShipmentHistoryView: View {
    @StateObject private var viewModel = ShipmentHistoryViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Shipment History")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color.theme.textPrimary)
                
                HStack(spacing: 16) {
                    Text("\(viewModel.completedShipments.count) completed shipments")
                    Text("Last updated \(viewModel.formatDate(viewModel.lastUpdated))")
                }
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color.theme.textSecondary)
            }
            .padding(.horizontal, 32)
            .padding(.top, 24)
            
            HStack(alignment: .center, spacing: 16) {
                Text("Shipment ID").frame(width: 110, alignment: .leading)
                Text("Origin").frame(maxWidth: .infinity, alignment: .leading)
                Text("Destination").frame(maxWidth: .infinity, alignment: .leading)
                Text("Plate Number").frame(maxWidth: .infinity, alignment: .leading)
                Text("Driver Name").frame(maxWidth: .infinity, alignment: .leading)
                Text("Shipment Date").frame(maxWidth: .infinity, alignment: .leading)
                Text("Arrival Date").frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer().frame(width: 44)
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(Color.theme.textSecondary)
            .padding(.horizontal, 56)
            
            if viewModel.isLoading && viewModel.completedShipments.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.completedShipments) { shipment in
                            ShipmentHistoryRowComponent(
                                shipmentID: "#\(shipment.id.uuidString.prefix(8).uppercased())",
                                startLatitude: shipment.startLatitude,
                                startLongitude: shipment.startLongitude,
                                endLatitude: shipment.endLatitude ?? 0.0,
                                endLongitude: shipment.endLongitude ?? 0.0,
                                truckPlate: shipment.truckPlateNumber,
                                driverName: shipment.driver.name,
                                shipmentDate: viewModel.formatDate(shipment.startDate),
                                shipmentTime: viewModel.formatTime(shipment.startDate),
                                arrivalDate: viewModel.formatDate(shipment.endDate ?? Date()),
                                arrivalTime: viewModel.formatTime(shipment.endDate ?? Date()),
                                statusColor: Color.theme.primary
                            )
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
                .refreshable {
                    await viewModel.loadHistoryData()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.clear)
        .task {
            await viewModel.loadHistoryData()
        }
    }
}

#Preview(traits: .landscapeLeft) {
    ShipmentHistoryView()
}
