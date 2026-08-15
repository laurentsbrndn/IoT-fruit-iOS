//
//  WSTelemetryDTO.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 16/08/26.
//

import Foundation

struct WSTelemetryDTO: Decodable {
    let deviceId: String
    let log: [WSTelemetryItem]
    
    enum CodingKeys: String, CodingKey {
        case deviceId = "device_id"
        case log
    }
}

struct WSTelemetryItem: Decodable {
    let temperature: Double?
    let humidity: Double?
}
