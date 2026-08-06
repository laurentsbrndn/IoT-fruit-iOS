//
//  DriverRepository.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 06/08/26.
//

import Foundation

protocol DriverRepositoryProtocol {
    func fetchDriver(id: String) async throws -> Driver
}

final class DriverRepository: DriverRepositoryProtocol {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    func fetchDriver(id: String) async throws -> Driver {
        let endpoint = APIEndpoint.getDriverName(id: id)
        return try await apiClient.request(endpoint, responseType: Driver.self)
    }
}
