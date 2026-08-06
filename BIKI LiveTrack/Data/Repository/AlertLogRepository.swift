//
//  AlertLogRepository.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 06/08/26.
//

import Foundation

protocol AlertLogRepositoryProtocol {
    func fetchAllAlerts() async throws -> [AlertLog]
    func fetchAlerts(byShipmentID shipmentID: String) async throws -> [AlertLog]
}

final class AlertLogRepository: AlertLogRepositoryProtocol {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    func fetchAllAlerts() async throws -> [AlertLog] {
        let endpoint = APIEndpoint.getAlerts
        return try await apiClient.request(endpoint, responseType: [AlertLog].self)
    }
    
    func fetchAlerts(byShipmentID shipmentID: String) async throws -> [AlertLog] {
        let endpoint = APIEndpoint.getAlertsByShipment(id: shipmentID)
        return try await apiClient.request(endpoint, responseType: [AlertLog].self)
    }
}
