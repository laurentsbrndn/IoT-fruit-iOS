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
    @Published var shipmentStatuses: [UUID: DeviceStatus] = [:]
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let shipmentRepository: ShipmentRepositoryProtocol
    private let alertLogRepository: AlertLogRepositoryProtocol
    
    init(
        shipmentRepository: ShipmentRepositoryProtocol = ShipmentRepository(),
        alertLogRepository: AlertLogRepositoryProtocol = AlertLogRepository()
    ) {
        self.shipmentRepository = shipmentRepository
        self.alertLogRepository = alertLogRepository
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
            
            await fetchLatestAlerts(for: active)
            
//            for shipment in self.deliveredShipments {
//                self.shipmentStatuses[shipment.id] = .delivered
//            }
            
        } catch {
            self.errorMessage = error.localizedDescription
            print("Gagal mengambil data shipments: \(error)")
        }
        
        self.isLoading = false
    }
    
    private func fetchLatestAlerts(for shipments: [Shipment]) async {
        for shipment in shipments {
            do {
                let alerts = try await alertLogRepository.fetchAlerts(byShipmentID: shipment.id.uuidString)
                
                let sortedAlerts = alerts.sorted { $0.timestamps > $1.timestamps }
                
                if let latestAlert = sortedAlerts.first {
                    self.shipmentStatuses[shipment.id] = DeviceStatus.from(
                        category: latestAlert.alertType.category,
                        title: latestAlert.alertType.title
                    )
                } else {
                    self.shipmentStatuses[shipment.id] = .ideal
                }
            } catch {
                print("Gagal mengambil alert untuk shipment \(shipment.id): \(error)")
                self.shipmentStatuses[shipment.id] = .ideal
            }
        }
    }
}
