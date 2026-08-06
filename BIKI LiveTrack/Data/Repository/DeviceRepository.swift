//
//  DeviceRepository.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 06/08/26.
//

import Foundation

protocol DeviceRepositoryProtocol {
    func fetchAllDevices() async throws -> [Device]
    func fetchDevice(byName name: String) async throws -> Device
}

final class DeviceRepository: DeviceRepositoryProtocol {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    func fetchAllDevices() async throws -> [Device] {
        let endpoint = APIEndpoint.getDevices
        return try await apiClient.request(endpoint, responseType: [Device].self)
    }
    
    func fetchDevice(byName name: String) async throws -> Device {
        let endpoint = APIEndpoint.getDeviceByName(name: name)
        return try await apiClient.request(endpoint, responseType: Device.self)
    }
}
