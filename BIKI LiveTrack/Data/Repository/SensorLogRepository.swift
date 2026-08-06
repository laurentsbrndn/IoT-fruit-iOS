//
//  SensorLogRepository.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 06/08/26.
//

import Foundation

protocol SensorLogRepositoryProtocol {
    func fetchAllSensors() async throws -> [SensorLog]
    func fetchSensors(byShipmentID shipmentID: String) async throws -> [SensorLog]
}

final class SensorLogRepository: SensorLogRepositoryProtocol {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    func fetchAllSensors() async throws -> [SensorLog] {
        let endpoint = APIEndpoint.getSensors
        return try await apiClient.request(endpoint, responseType: [SensorLog].self)
    }
    
    func fetchSensors(byShipmentID shipmentID: String) async throws -> [SensorLog] {
        let endpoint = APIEndpoint.getSensorsByShipment(id: shipmentID)
        return try await apiClient.request(endpoint, responseType: [SensorLog].self)
    }
}
