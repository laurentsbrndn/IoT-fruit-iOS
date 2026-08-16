//
//  AlertLog.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 06/08/26.
//

import Foundation

struct AlertLog: Identifiable, Codable {
    let id: UUID
    let alertType: AlertType
    let timestamps: Date
    
    private let shipment: ParentRef
    private let sensorLog: ParentRef
    
    var shipmentID: UUID { shipment.id }
    var sensorLogID: UUID { sensorLog.id }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case alertType = "alertType"
        case shipment = "shipment"
        case sensorLog = "sensorLog"
        case timestamps = "timestamps"
    }
    
    struct ParentRef: Codable {
        let id: UUID
    }
}
