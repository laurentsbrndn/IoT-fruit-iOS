//
//  Shipment.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 06/08/26.
//

import Foundation

struct Shipment: Identifiable, Codable {
    let id: UUID
    let device: Device
    let driver: Driver
    let truckPlateNumber: String
    let startDate: Date
    let endDate: Date?
    let startLatitude: Double
    let startLongitude: Double
    let endLatitude: Double?
    let endLongitude: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case device
        case driver      
        case truckPlateNumber
        case startDate
        case endDate
        case startLatitude
        case startLongitude
        case endLatitude
        case endLongitude
    }
}

struct UpdateShipmentDTO: Codable {
    let deviceId: String
    let driverId: String
    let truckPlateNumber: String
    let startDate: Date
    let endDate: Date?
    let startLatitude: Double
    let startLongitude: Double
    let endLatitude: Double?
    let endLongitude: Double?
}
