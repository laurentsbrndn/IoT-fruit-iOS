//
//  Driver.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 06/08/26.
//

import Foundation

struct Driver: Identifiable, Codable {
    let id: UUID
    let name: String
    let phoneNumber: String
    
    enum CodingKeys: String, CodingKey {
        case id = "driver_id"
        case name = "driver_name"
        case phoneNumber = "driver_phone_number"
    }
}
