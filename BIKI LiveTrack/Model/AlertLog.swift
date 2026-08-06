//
//  AlertLog.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 06/08/26.
//

import Foundation

struct AlertLog: Identifiable, Codable {
    let id: UUID
    let alertTypeID: UUID
    let shipmentID: UUID
    let sensorLogID: UUID
    let timestamps: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "alert_log_id"
        case alertTypeID = "alert_type_id"
        case shipmentID = "shipment_id"
        case sensorLogID = "sensor_log_id"
        case timestamps = "timestamps"
    }
}
