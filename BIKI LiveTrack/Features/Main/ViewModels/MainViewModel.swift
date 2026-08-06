//
//  MainViewModel.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 06/08/26.
//

import Foundation
import Combine

@MainActor
final class MainViewModel: ObservableObject {
    @Published var activeShipments: [Shipment] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let shipmentRepository: ShipmentRepositoryProtocol
    
    init(shipmentRepository: ShipmentRepositoryProtocol = ShipmentRepository()) {
        self.shipmentRepository = shipmentRepository
    }
    
    func loadActiveShipments() async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let shipments = try await shipmentRepository.fetchActiveShipments()
            self.activeShipments = shipments
        }
        catch {
            self.errorMessage = error.localizedDescription
            print("Gagal mengambil active shipments: \(error)")
        }
        
        self.isLoading = false
    }
}
