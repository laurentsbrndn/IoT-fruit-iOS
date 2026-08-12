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
            HStack(alignment: .center) {
                Text("Shipment History")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color.theme.textPrimary)
                
                Spacer()
                
                HStack(spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color.theme.textSecondary)
                        TextField("Search", text: $viewModel.searchText)
                            .foregroundColor(Color.theme.textPrimary)
                            .autocorrectionDisabled()
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 44)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .frame(width: 280)
                    
                    ShipmentHistoryMenuComponent(viewModel: viewModel)
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 24)
            .onChange(of: viewModel.searchText) { _ in
                viewModel.currentPage = 1
            }
            
            HStack {
                HStack(spacing: 8) {
                    Text("\(viewModel.completedShipments.count) completed shipments")
                    Text("•")
                    Text("Last updated \(viewModel.formatDate(viewModel.lastUpdated))")
                }
                
                Spacer()
                
                Text(viewModel.showingText)
            }
            .font(.system(size: 14, weight: .regular))
            .foregroundColor(Color.theme.textSecondary)
            .padding(.horizontal, 32)
            
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
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(Color.theme.primary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 32)
            
            if viewModel.isLoading && viewModel.completedShipments.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ZStack(alignment: .bottom) {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            ForEach(Array(viewModel.paginatedShipments.enumerated()), id: \.element.id) { index, shipment in
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
                                    statusColor: Color.theme.primary,
                                    rowBackgroundColor: index % 2 == 0 ? Color.theme.TableRow1 : Color.theme.TableRow2
                                )
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 80)
                    }
                    .refreshable {
                        await viewModel.loadHistoryData()
                    }
                    
                    HStack(spacing: 16) {
                        Button(action: {
                            if viewModel.currentPage > 1 { viewModel.currentPage -= 1 }
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(viewModel.currentPage > 1 ? .primary : Color.theme.textSecondary)
                        }
                        .disabled(viewModel.currentPage == 1)
                        
                        ForEach(1..<min(5, viewModel.totalPages + 1), id: \.self) { page in
                            Button(action: {
                                viewModel.currentPage = page
                            }) {
                                Text("\(page)")
                                    .font(.system(size: 14, weight: viewModel.currentPage == page ? .bold : .regular))
                                    .frame(width: 32, height: 32)
                                    .background(viewModel.currentPage == page ? Color.white : Color.clear)
                                    .clipShape(Circle())
                                    .foregroundColor(viewModel.currentPage == page ? .primary : Color.theme.textSecondary)
                            }
                        }
                        
                        if viewModel.totalPages > 5 {
                            Text("...")
                                .foregroundColor(Color.theme.textSecondary)
                            
                            Button(action: {
                                viewModel.currentPage = viewModel.totalPages
                            }) {
                                Text("\(viewModel.totalPages)")
                                    .font(.system(size: 14))
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(Color.theme.textSecondary)
                            }
                        }
                        
                        Button(action: {
                            if viewModel.currentPage < viewModel.totalPages { viewModel.currentPage += 1 }
                        }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(viewModel.currentPage < viewModel.totalPages ? .primary : Color.theme.textSecondary)
                        }
                        .disabled(viewModel.currentPage == viewModel.totalPages)
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                    .frame(maxWidth: .infinity)
                    .background(Color.theme.background)
                    .zIndex(1)
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
