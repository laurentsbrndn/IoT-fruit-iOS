//
//  AddShipmentViewModel.swift
//  BIKI LiveTrack
//
//  Created by Grace Frendy on 17/08/26.
//

import Foundation
import Observation

@Observable
final class AddShipmentViewModel {
    // MARK: - Form Properties
    var originLocation: String = ""
    var destinationLocation: String = ""
    var truckPlateNumber: String = ""
    var selectedDriver: String = ""
    var selectedDeviceID: String = ""
    
    // MARK: - Data Source Options
    let availableDrivers: [String] = [
        "Bayu Sapta Haji",
        "Budi Santoso",
        "Ahmad Fauzi"
    ]
    
    let availableDevices: [String] = [
        "DEV-11750-A",
        "DEV-11750-B",
        "DEV-20419-C"
    ]
    
    // MARK: - Validation
    var isFormValid: Bool {
        !originLocation.trimmingCharacters(in: .whitespaces).isEmpty &&
        !destinationLocation.trimmingCharacters(in: .whitespaces).isEmpty &&
        !truckPlateNumber.trimmingCharacters(in: .whitespaces).isEmpty &&
        !selectedDriver.isEmpty &&
        !selectedDeviceID.isEmpty
    }
    
    // MARK: - Actions
    func startShipping(onComplete: () -> Void) {
        guard isFormValid else { return }
        // Handle shipment submission logic
        onComplete()
    }
}
