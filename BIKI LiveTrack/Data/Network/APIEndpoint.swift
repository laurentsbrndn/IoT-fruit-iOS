//
//  APIEndpoint.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 06/08/26.
//

import Foundation

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum APIEndpoint {
    case getShipments
    case getActiveShipments
    case getShipment(id: String)
    case createShipment(payload: Data)
    case updateShipment(id: String, payload: Data)
    case finishShipment(id: String)
    
    case getSensors
    case getSensorsByShipment(id: String)
    
    case getAlerts
    case getAlertsByShipment(id: String)
    
    case getDevices
    case getDeviceByName(name: String)
    case getDriverName(id: String)
    
    var path: String {
        switch self {
        case .getShipments, .createShipment: return "/api/shipments"
        case .getActiveShipments: return "/api/shipments/active"
        case .getShipment(let id): return "/api/shipments/\(id)"
        case .updateShipment(let id, _): return "/api/shipments/\(id)"
        case .finishShipment(let id): return "/api/shipments/\(id)/finish"
            
        case .getSensors: return "/api/sensors"
        case .getSensorsByShipment(let id): return "/api/sensors/shipment/\(id)"
            
        case .getAlerts: return "/api/alerts"
        case .getAlertsByShipment(let id): return "/api/alerts/shipment/\(id)"
            
        case .getDevices: return "/api/devices"
        case .getDeviceByName(let name): return "/api/devices/name/\(name)"
            
        case .getDriverName(let id): return "/api/drivers/\(id)/name"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .createShipment: return .post
        case .updateShipment: return .put
        case .finishShipment: return .patch
        default: return .get
        }
    }
    
    var body: Data? {
        switch self {
        case .createShipment(let payload): return payload
        case .updateShipment(_, let payload): return payload
        default: return nil
        }
    }
}
