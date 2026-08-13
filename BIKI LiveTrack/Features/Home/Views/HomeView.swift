//
//  HomeView.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 06/08/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    let cardWidth: CGFloat = 340

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 48) {

                // MARK: - Recently Delivered Section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Recently Delivered (\(viewModel.deliveredShipments.count))")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color.theme.textPrimary)
                        // Menggunakan 24 untuk menyelaraskan dengan tombol sidebar bawaan iPadOS
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
                        // ScrollView Horizontal untuk Recently Delivered
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
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
                                    .frame(width: cardWidth) // Memaksa ukuran tetap
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                }
                .padding(.top, 16)

                // MARK: - Currently Live Section
                VStack(alignment: .leading, spacing: 20) {
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
                        // ScrollView agar kolom Currently Live juga aman jika layarnya sangat sempit
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .top, spacing: 16) {
                                
                                // Kolom 1: Ideal
                                VStack(alignment: .leading, spacing: 16) {
                                    CategoryHeaderView(color: .green, title: "All systems in ideal conditions", count: idealShipments.count)
                                    ForEach(idealShipments) { shipment in
                                        ShipmentLiveInfoCardComponent(
                                            shipmentID: "#\(shipment.id.uuidString.prefix(8).uppercased())",
                                            status: viewModel.shipmentStatuses[shipment.id] ?? .ideal,
                                            latitude: shipment.endLatitude ?? 0.0,
                                            longitude: shipment.endLongitude ?? 0.0,
                                            driverName: shipment.driver.name,
                                            driverContact: shipment.driver.phoneNumber
                                        )
                                        .frame(width: cardWidth)
                                    }
                                }
                                
                                // Kolom 2: Warning
                                VStack(alignment: .leading, spacing: 16) {
                                    CategoryHeaderView(color: .yellow, title: "Need attentions", count: warningShipments.count)
                                    ForEach(warningShipments) { shipment in
                                        ShipmentLiveInfoCardComponent(
                                            shipmentID: "#\(shipment.id.uuidString.prefix(8).uppercased())",
                                            status: viewModel.shipmentStatuses[shipment.id] ?? .ideal,
                                            latitude: shipment.endLatitude ?? 0.0,
                                            longitude: shipment.endLongitude ?? 0.0,
                                            driverName: shipment.driver.name,
                                            driverContact: shipment.driver.phoneNumber
                                        )
                                        .frame(width: cardWidth)
                                    }
                                }
                                
                                // Kolom 3: Offline
                                VStack(alignment: .leading, spacing: 16) {
                                    CategoryHeaderView(color: .red, title: "Devices are not connected", count: offlineShipments.count)
                                    ForEach(offlineShipments) { shipment in
                                        ShipmentLiveInfoCardComponent(
                                            shipmentID: "#\(shipment.id.uuidString.prefix(8).uppercased())",
                                            status: viewModel.shipmentStatuses[shipment.id] ?? .ideal,
                                            latitude: shipment.endLatitude ?? 0.0,
                                            longitude: shipment.endLongitude ?? 0.0,
                                            driverName: shipment.driver.name,
                                            driverContact: shipment.driver.phoneNumber
                                        )
                                        .frame(width: cardWidth)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                }
            }
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
        // Memindahkan Tombol Plus agar menempel sejajar di kanan atas (seperti Gambar 2)
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
    
    // MARK: - Helper Pengelompokkan (Grouping) Kategori Status
    
    private var idealShipments: [Shipment] {
        viewModel.activeShipments.filter { viewModel.shipmentStatuses[$0.id] == .ideal }
    }
    
    private var warningShipments: [Shipment] {
        // Catatan: Jika enum Anda memiliki case khusus untuk warning (misal: .warning),
        // ganti bagian string comparison di bawah ini dengan `== .warning`
        viewModel.activeShipments.filter { String(describing: viewModel.shipmentStatuses[$0.id]).lowercased().contains("warning") }
    }
    
    private var offlineShipments: [Shipment] {
        // Catatan: Jika enum Anda memiliki case khusus untuk offline (misal: .offline),
        // ganti bagian string comparison di bawah ini dengan `== .offline`
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

// MARK: - Sub-Komponen Header Kategori (Titik Warna & Judul)
struct CategoryHeaderView: View {
    let color: Color
    let title: String
    let count: Int
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            Spacer()
            Text("\(count)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(color == .red ? .red : .secondary)
        }
        .padding(.bottom, 8)
    }
}

#Preview(traits: .landscapeLeft) {
    NavigationStack {
        HomeView()
    }
}
