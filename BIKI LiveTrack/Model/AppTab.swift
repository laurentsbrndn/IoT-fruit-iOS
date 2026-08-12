//
//  AppTab.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 10/08/26.
//

import SwiftUI

enum AppTab: String, CaseIterable {
    case home = "Home"
    case shipmentHistory = "Shipment History"
    
    var icon: String {
        switch self {
        case .home: return "house"
        case .shipmentHistory: return "doc.text"
        }
    }
}
