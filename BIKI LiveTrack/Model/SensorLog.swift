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
    let latitude: Double?
    let longitude: Double?
    let batteryPercentage: Double?
    let timestamps: Date?
    
    enum CodingKeys: String, CodingKey {
        case id = "sensor_log_id"
        case shipmentID = "shipment_id"
        case temperature = "sensor_log_temperature"
        case humidity = "sensor_log_humidity"
        case latitude = "sensor_log_latitude"
        case longitude = "sensor_log_longitude"
        case batteryPercentage = "sensor_log_battery_percentage"
        case timestamps = "sensor_log_timestamps"
    }
}
