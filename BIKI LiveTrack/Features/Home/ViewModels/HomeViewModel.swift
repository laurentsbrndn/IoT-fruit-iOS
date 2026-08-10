//
//  HomeViewModel.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 06/08/26.
//

import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var activeShipments: [Shipment] = []
    @Published var deliveredShipments: [Shipment] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let shipmentRepository: ShipmentRepositoryProtocol
    
    init(shipmentRepository: ShipmentRepositoryProtocol = ShipmentRepository()) {
        self.shipmentRepository = shipmentRepository
    }
    
    func loadHomeData() async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            async let fetchActive = shipmentRepository.fetchActiveShipments()
            async let fetchAll = shipmentRepository.fetchAllShipments()
            
            let (active, all) = try await (fetchActive, fetchAll)
            
            self.activeShipments = active
            
            self.deliveredShipments = all
                .filter { $0.endDate != nil }
                .sorted { ($0.endDate ?? Date.distantPast) > ($1.endDate ?? Date.distantPast) }
            
        } catch {
            self.errorMessage = error.localizedDescription
            print("Gagal mengambil data shipments: \(error)")
        }
        
        self.isLoading = false
    }
}
