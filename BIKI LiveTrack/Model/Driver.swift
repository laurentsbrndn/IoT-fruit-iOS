//
//  Driver.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 06/08/26.
//

import Foundation

struct Driver: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let phoneNumber: String
    
    enum CodingKeys: String, CodingKey {
        case id, driver_id
        case name, driverName, driver_name
        case phoneNumber, driverPhoneNumber, driver_phone_number
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ??
                      container.decode(UUID.self, forKey: .driver_id)
        
        self.name = try container.decodeIfPresent(String.self, forKey: .driverName) ??
                        container.decodeIfPresent(String.self, forKey: .driver_name) ??
                        container.decode(String.self, forKey: .name)
        
        self.phoneNumber = try container.decodeIfPresent(String.self, forKey: .driverPhoneNumber) ??
                               container.decodeIfPresent(String.self, forKey: .driver_phone_number) ??
                               container.decodeIfPresent(String.self, forKey: .phoneNumber) ??
                               "-" 
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .driverName)
        try container.encode(phoneNumber, forKey: .driverPhoneNumber)
    }
}
