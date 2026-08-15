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
    let category: String
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case severity = "severity"
        case category = "category"
        case description = "description"
    }
}
