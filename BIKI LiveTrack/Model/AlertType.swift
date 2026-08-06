//
//  AlertType.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 06/08/26.
//

import Foundation

struct AlertType: Identifiable, Codable {
    let id: UUID
    let title: String
    let severity: String
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "alert_type_id"
        case title = "alert_types_title"
        case severity = "alert_types_severity"
        case description = "alert_types_description"
    }
}
