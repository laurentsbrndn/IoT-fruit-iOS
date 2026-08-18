//
//  Device.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 06/08/26.
//

import Foundation

struct Device: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id, device_id
        case name, deviceName, device_name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ??
                      container.decode(UUID.self, forKey: .device_id)
        
        self.name = try container.decodeIfPresent(String.self, forKey: .deviceName) ??
                        container.decodeIfPresent(String.self, forKey: .device_name) ??
                        container.decode(String.self, forKey: .name)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .deviceName)
    }
}
