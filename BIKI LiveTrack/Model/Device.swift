//
//  Device.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 06/08/26.
//

import Foundation

struct Device: Identifiable, Codable {
    let id: UUID
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "deviceName"
    }
}
