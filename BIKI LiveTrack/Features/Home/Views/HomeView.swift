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
        ZStack(alignment: .topTrailing) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 48) {

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
                            }
                        }
                    }
                    .padding(.top, 30)

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
                                    ShipmentLiveInfoCardComponent(
                                        shipmentID: "#\(shipment.id.uuidString.prefix(8).uppercased())",
                                        status: viewModel.shipmentStatuses[shipment.id] ?? .ideal,
                                        latitude: shipment.endLatitude ?? 0.0,
                                        longitude: shipment.endLongitude ?? 0.0,
                                        driverName: shipment.driver.name,
                                        driverContact: shipment.driver.phoneNumber
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

            Button(action: {
                print("Tombol Plus ditekan dari HomeView")
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 48, height: 48)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.trailing, 32)
            .offset(y: -48)
        }
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
    HomeView()
}
