//
//  ShipmentHistoryViewModel.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 11/08/26.
//

import Foundation
import Combine

@MainActor
final class ShipmentHistoryViewModel: ObservableObject {
    @Published var completedShipments: [Shipment] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var lastUpdated: Date = Date()
    
    private let shipmentRepository: ShipmentRepositoryProtocol
    
    init(shipmentRepository: ShipmentRepositoryProtocol = ShipmentRepository()) {
        self.shipmentRepository = shipmentRepository
    }
    
    func loadHistoryData() async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let allShipments = try await shipmentRepository.fetchAllShipments()
            
            self.completedShipments = allShipments
                .filter { $0.endDate != nil }
                .sorted { ($0.endDate ?? Date.distantPast) > ($1.endDate ?? Date.distantPast) }
            
            self.lastUpdated = Date()
            
        } catch {
            self.errorMessage = error.localizedDescription
            print("Gagal mengambil data riwayat shipments: \(error)")
        }
        
        self.isLoading = false
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: date)
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
