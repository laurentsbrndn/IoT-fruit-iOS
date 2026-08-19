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
        case id, shipment_id
        case device
        case driver
        case truckPlateNumber, shipment_truck_plate_number
        case startDate, shipment_start_date
        case endDate, shipment_end_date
        case startLatitude, shipment_start_latitude
        case startLongitude, shipment_start_longitude
        case endLatitude, shipment_end_latitude
        case endLongitude, shipment_end_longitude
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ??
        container.decode(UUID.self, forKey: .shipment_id)
        
        self.device = try container.decode(Device.self, forKey: .device)
        self.driver = try container.decode(Driver.self, forKey: .driver)
        
        self.truckPlateNumber = try container.decodeIfPresent(String.self, forKey: .truckPlateNumber) ??
        container.decode(String.self, forKey: .shipment_truck_plate_number)
        
        self.startDate = try container.decodeIfPresent(Date.self, forKey: .startDate) ??
        container.decode(Date.self, forKey: .shipment_start_date)
        
        self.endDate = try container.decodeIfPresent(Date.self, forKey: .endDate) ??
        container.decodeIfPresent(Date.self, forKey: .shipment_end_date)
        
        self.startLatitude = try container.decodeIfPresent(Double.self, forKey: .startLatitude) ??
        container.decode(Double.self, forKey: .shipment_start_latitude)
        
        self.startLongitude = try container.decodeIfPresent(Double.self, forKey: .startLongitude) ??
        container.decode(Double.self, forKey: .shipment_start_longitude)
        
        self.endLatitude = try container.decodeIfPresent(Double.self, forKey: .endLatitude) ??
        container.decodeIfPresent(Double.self, forKey: .shipment_end_latitude)
        
        self.endLongitude = try container.decodeIfPresent(Double.self, forKey: .endLongitude) ??
        container.decodeIfPresent(Double.self, forKey: .shipment_end_longitude)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(device, forKey: .device)
        try container.encode(driver, forKey: .driver)
        try container.encode(truckPlateNumber, forKey: .truckPlateNumber)
        try container.encode(startDate, forKey: .startDate)
        try container.encodeIfPresent(endDate, forKey: .endDate)
        try container.encode(startLatitude, forKey: .startLatitude)
        try container.encode(startLongitude, forKey: .startLongitude)
        try container.encodeIfPresent(endLatitude, forKey: .endLatitude)
        try container.encodeIfPresent(endLongitude, forKey: .endLongitude)
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
    
//    enum CodingKeys: String, CodingKey {
//        case deviceId = "device_id"
//        case driverId = "driver_id"
//        case truckPlateNumber = "shipment_truck_plate_number"
//        case startDate = "shipment_start_date"
//        case endDate = "shipment_end_date"
//        case startLatitude = "shipment_start_latitude"
//        case startLongitude = "shipment_start_longitude"
//        case endLatitude = "shipment_end_latitude"
//        case endLongitude = "shipment_end_longitude"
//    }
}
