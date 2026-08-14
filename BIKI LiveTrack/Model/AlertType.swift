////
////  AlertType.swift
////  BIKI LiveTrack
////
////  Created by Laurentius Brandon Vikario on 06/08/26.
////
//
//import Foundation
//
//struct AlertType: Identifiable, Codable {
//    let id: UUID
//    let title: String
//    let severity: String
//    let category: String
//    let description: String?
//    
//    enum CodingKeys: String, CodingKey {
//        case id = "alert_type_id"
//        case title = "alert_types_title"
//        case severity = "alert_types_severity"
//        case category = "alert_types_category"
//        case description = "alert_types_description"
//    }
//}
//
//extension AlertType {
//    var iconName: String {
//        switch title {
//        case "High Humidity": return "humidity.fill"
//        case "Low Humidity": return "humidity"
//        case "Humidity Normalized": return "drop.fill"
//        case "Lost Connection": return "wifi.slash"
//        case "Connection Back": return "wifi"
//        case "High Temperature": return "thermometer.sun"
//        case "Low Temperature": return "thermometer.snowflake"
//        case "Temperature Normalized": return "thermometer.variable"
//        default: return "bell.fill"
//        }
//    }
//}


import Foundation

enum AlertType: String, Codable, CaseIterable {
    case highHumidity = "High Humidity"
    case lowHumidity = "Low Humidity"
    case humidityNormalized = "Humidity Normalized"
    case lostConnection = "Lost Connection"
    case connectionBack = "Connection Back"
    case highTemperature = "High Temperature"
    case lowTemperature = "Low Temperature"
    case temperatureNormalized = "Temperature Normalized"
    
    var title: String {
        return self.rawValue
    }
    
    var description: String {
        switch self {
        case .highHumidity:
            return "Humidity is above the ideal range"
        case .lowHumidity:
            return "Humidity has dropped below the ideal range"
        case .humidityNormalized:
            return "Humidity is back within the ideal range"
        case .lostConnection:
            return "Sensor stopped sending data"
        case .connectionBack:
            return "Sensor is back online and reporting normally"
        case .highTemperature:
            return "Temperature is above the ideal range"
        case .lowTemperature:
            return "Temperature has dropped below the ideal range"
        case .temperatureNormalized:
            return "Temperature is back within the ideal range"
        }
    }
    
    var iconName: String {
        switch self {
        case .highHumidity: return "humidity.fill"
        case .lowHumidity: return "humidity"
        case .humidityNormalized: return "drop.fill"
        case .lostConnection: return "wifi.slash"
        case .connectionBack: return "wifi"
        case .highTemperature: return "thermometer.sun"
        case .lowTemperature: return "thermometer.snowflake"
        case .temperatureNormalized: return "thermometer.variable"
        }
    }
    
    var category: String {
        switch self {
        case .highHumidity, .lowHumidity, .humidityNormalized:
            return "Humidity"
        case .highTemperature, .lowTemperature, .temperatureNormalized:
            return "Temperature"
        case .lostConnection, .connectionBack:
            return "Connectivity"
        }
    }
    
    var severity: String {
        switch self {
        case .highHumidity, .lowHumidity, .highTemperature, .lowTemperature, .lostConnection:
            return "Warning"
        case .humidityNormalized, .temperatureNormalized, .connectionBack:
            return "Normal"
        }
    }
}
