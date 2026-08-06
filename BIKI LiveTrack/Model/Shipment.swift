//
//  Shipment.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 06/08/26.
//

import Foundation

struct Shipment: Identifiable, Codable {
    let id: UUID
    let deviceID: UUID
    let driverID: UUID
    let truckPlateNumber: String
    let startDate: Date
    let endDate: Date?
    let startLatitude: Double
    let startLongitude: Double
    let endLatitude: Double?
    let endLongitude: Double?
    
    enum CodingKeys: String, CodingKey {
        case id = "shipment_id"
        case deviceID = "device_id"
        case driverID = "driver_id"
        case truckPlateNumber = "shipment_truck_plate_number"
        case startDate = "shipment_start_date"
        case endDate = "shipment_end_date"
        case startLatitude = "shipment_start_latitude"
        case startLongitude = "shipment_start_longitude"
        case endLatitude = "shipment_end_latitude"
        case endLongitude = "shipment_end_longitude"
    }
}
