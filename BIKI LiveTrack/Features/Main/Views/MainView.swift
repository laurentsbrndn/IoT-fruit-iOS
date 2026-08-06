//
//  MainView.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 06/08/26.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.activeShipments.isEmpty {
                    ProgressView("Memuat data pengiriman...")
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.theme.primary))
                } else if let errorMessage = viewModel.errorMessage, viewModel.activeShipments.isEmpty {
                    ErrorStateView(message: errorMessage) {
                        Task { await viewModel.loadActiveShipments() }
                    }
                } else if viewModel.activeShipments.isEmpty {
                    Text("Tidak ada pengiriman aktif saat ini.")
                        .font(.app.body)
                        .foregroundColor(Color.theme.textSecondary)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.activeShipments) { shipment in
                                ShipmentRowCard(shipment: shipment)
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.loadActiveShipments()
                    }
                }
            }
            .navigationTitle("Active Shipments")
            .task {
                await viewModel.loadActiveShipments()
            }
        }
    }
}

#Preview {
    MainView()
}
