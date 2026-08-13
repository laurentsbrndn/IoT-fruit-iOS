////
////  SensorLog.swift
////  BIKI LiveTrack
////
////  Created by Laurentius Brandon Vikario on 06/08/26.
////

import Foundation

struct SensorLog: Identifiable, Codable {
    let id: UUID
    let temperature: Double?
    let humidity: Double?
    let latitude: [Double]?
    let longitude: [Double]?
    let timestamps: Date?
    
    let shipment: ShipmentReference
    
    struct ShipmentReference: Codable {
        let id: UUID
    }
    
    var shipmentID: UUID {
        return shipment.id
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
