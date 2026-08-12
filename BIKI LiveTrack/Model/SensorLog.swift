//
//  SensorLog.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 06/08/26.
//

import Foundation

struct SensorLog: Identifiable, Codable {
    let id: UUID
    let shipmentID: UUID
    let temperature: Double?
    let humidity: Double?
    let latitude: [Double]?
    let longitude: [Double]?
    let timestamps: Date?
    
    enum CodingKeys: String, CodingKey {
        case id = "sensor_log_id"
        case shipmentID = "shipment_id"
        case temperature = "sensor_log_temperature"
        case humidity = "sensor_log_humidity"
        case latitude = "sensor_log_latitude"
        case longitude = "sensor_log_longitude"
        case timestamps = "sensor_log_timestamps"
    }
    
    var averageLatitude: Double? {
        guard let latArray = latitude, !latArray.isEmpty else { return nil }
        let sum = latArray.reduce(0, +)
        return sum / Double(latArray.count)
    }
    
    var averageLongitude: Double? {
        guard let lonArray = longitude, !lonArray.isEmpty else { return nil }
        let sum = lonArray.reduce(0, +)
        return sum / Double(lonArray.count)
    }
}
