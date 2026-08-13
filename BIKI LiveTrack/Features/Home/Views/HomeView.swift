//
//  HomeView.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 06/08/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    // Memperbesar panjang card history agar lebih jelas terlihat scrollable ke kanan
    let historyCardWidth: CGFloat = 420

    var body: some View {
        // Mengganti ScrollView utama dengan VStack agar tinggi halaman tetap/fix
        VStack(alignment: .leading, spacing: 32) {

            // MARK: - Recently Delivered Section
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
                                .frame(width: historyCardWidth) // Memaksa ukuran yang lebih panjang
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
            }
            .padding(.top, 16)

            // MARK: - Currently Live Section
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
                    // HStack ini membagi sisa layar menjadi 3 kolom rata
                    HStack(alignment: .top, spacing: 16) {
                        
                        // Kolom 1: Ideal
                        liveColumnView(
                            title: "All systems in ideal conditions",
                            dotColor: Color.theme.primaryGreen,
                            count: idealShipments.count,
                            shipments: idealShipments
                        )
                        
                        // Kolom 2: Warning
                        liveColumnView(
                            title: "Need attentions",
                            dotColor: Color.theme.primaryYellow,
                            count: warningShipments.count,
                            shipments: warningShipments
                        )
                        
                        // Kolom 3: Offline
                        liveColumnView(
                            title: "Devices are not connected",
                            dotColor: Color.theme.primaryRed,
                            count: offlineShipments.count,
                            shipments: offlineShipments,
                            isCountHighlighted: true
                        )
                    }
                    .padding(.horizontal, 24)
                    // Membiarkan kolom mengisi seluruh sisa ruang tinggi layar
                    .frame(maxHeight: .infinity)
                }
            }
            .frame(maxHeight: .infinity)
        }
        .padding(.bottom, 24)
        .background(Color.clear)
        .refreshable {
            await viewModel.loadHomeData()
        }
        .task {
            await viewModel.loadHomeData()
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
    
    // MARK: - Helper Builder untuk Kolom Currently Live
    @ViewBuilder
    private func liveColumnView(title: String, dotColor: Color, count: Int, shipments: [Shipment], isCountHighlighted: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Header Kolom
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
                    // Highlight warna merah khusus untuk hitungan offline
                    .foregroundColor(isCountHighlighted ? dotColor : .secondary)
            }
            
            // ScrollView Vertikal HANYA untuk dalam container komponen ini
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(shipments) { shipment in
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
                .padding(.bottom, 16)
            }
        }
        .padding(16)
        // Background abu-abu untuk setiap kolom
        .background(Color.theme.FrameCard)
        .cornerRadius(16)
        // Masing-masing kolom membagi proporsi 1/3 layar (flex infinity)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
