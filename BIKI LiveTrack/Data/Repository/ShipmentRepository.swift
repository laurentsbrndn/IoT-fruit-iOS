//
//  ShipmentRepository.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 06/08/26.
//

import Foundation

import Foundation

protocol ShipmentRepositoryProtocol {
    func fetchAllShipments() async throws -> [Shipment]
    func fetchActiveShipments() async throws -> [Shipment]
    func fetchShipmentDetail(id: String) async throws -> Shipment
    func createShipment(payload: Data) async throws -> Shipment
    func updateShipment(id: String, payload: Data) async throws -> Shipment
    func finishShipment(id: String) async throws -> Shipment
}

final class ShipmentRepository: ShipmentRepositoryProtocol {
    
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    func fetchAllShipments() async throws -> [Shipment] {
        let endpoint = APIEndpoint.getShipments
        return try await apiClient.request(endpoint, responseType: [Shipment].self)
    }
    
    func fetchActiveShipments() async throws -> [Shipment] {
        let endpoint = APIEndpoint.getActiveShipments
        return try await apiClient.request(endpoint, responseType: [Shipment].self)
    }
    
    func fetchShipmentDetail(id: String) async throws -> Shipment {
        let endpoint = APIEndpoint.getShipment(id: id)
        return try await apiClient.request(endpoint, responseType: Shipment.self)
    }
    
    func createShipment(payload: Data) async throws -> Shipment {
        let endpoint = APIEndpoint.createShipment(payload: payload)
        return try await apiClient.request(endpoint, responseType: Shipment.self)
    }
    
    func updateShipment(id: String, payload: Data) async throws -> Shipment {
        let endpoint = APIEndpoint.updateShipment(id: id, payload: payload)
        return try await apiClient.request(endpoint, responseType: Shipment.self)
    }
    
    func finishShipment(id: String) async throws -> Shipment {
        let endpoint = APIEndpoint.finishShipment(id: id)
        return try await apiClient.request(endpoint, responseType: Shipment.self)
    }
}
