//
//  AddShipmentViewModel.swift
//  BIKI LiveTrack
//
//  Created by Grace Frendy on 17/08/26.
//

import Foundation
import Observation
import CoreLocation
import MapKit

@Observable
final class AddShipmentViewModel: NSObject, CLLocationManagerDelegate, MKLocalSearchCompleterDelegate {
    
    private let deviceRepo = DeviceRepository()
    private let driverRepo = DriverRepository()
    private let shipmentRepo = ShipmentRepository()
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var searchCompleter = MKLocalSearchCompleter()
    
    var originLocation: String = ""
    var destinationLocation: String = ""
    var truckPlateNumber: String = ""
    
    var selectedDriver: Driver? = nil
    var selectedDevice: Device? = nil
    
    var availableDrivers: [Driver] = []
    var availableDevices: [Device] = []
    var locationSuggestions: [MKLocalSearchCompletion] = []
    
    var isFetchingData = false
    var errorMessage: String?
    
    override init() {
        super.init()
        setupLocationManager()
        setupSearchCompleter()
    }
    
    func updateSearchQuery(for text: String) {
        if text.isEmpty {
            self.locationSuggestions = []
        } else {
            searchCompleter.queryFragment = text
        }
    }
    
    func fetchInitialData() async {
        isFetchingData = true
        do {
            async let fetchedDevices = deviceRepo.fetchAllDevices()
            async let fetchedDrivers = driverRepo.fetchAllDrivers()
            
            self.availableDevices = try await fetchedDevices
            self.availableDrivers = try await fetchedDrivers
            print("✅ Sukses fetch: \(self.availableDrivers.count) driver, \(self.availableDevices.count) device")
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ GAGAL FETCH API: \(error.localizedDescription)")
            print("❌ DETAIL ERROR: \(error)")
        }
        isFetchingData = false
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestCurrentLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let placemark = placemarks?.first {
                let address = [placemark.thoroughfare, placemark.locality].compactMap { $0 }.joined(separator: ", ")
                self?.originLocation = address.isEmpty ? "Current Location" : address
                self?.locationSuggestions = []
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Gagal mendapatkan lokasi: \(error.localizedDescription)")
    }
    
    private func setupSearchCompleter() {
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .address
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.locationSuggestions = completer.results
    }
    
    var isFormValid: Bool {
        !originLocation.trimmingCharacters(in: .whitespaces).isEmpty &&
        !destinationLocation.trimmingCharacters(in: .whitespaces).isEmpty &&
        !truckPlateNumber.trimmingCharacters(in: .whitespaces).isEmpty &&
        selectedDriver != nil &&
        selectedDevice != nil
    }
    
    func startShipping(onComplete: @escaping () -> Void) {
        guard isFormValid, let device = selectedDevice, let driver = selectedDriver else { return }
        
        Task {
            do {
                let startCoords = try await getCoordinates(from: originLocation)
                let endCoords = try await getCoordinates(from: destinationLocation)
                
                let payloadDict: [String: Any] = [
                    "device_id": device.id.uuidString,
                    "driver_id": driver.id.uuidString,
                    "truck_plate_number": truckPlateNumber,
                    "start_latitude": startCoords.latitude,
                    "start_longitude": startCoords.longitude,
                    "end_latitude": endCoords.latitude,
                    "end_longitude": endCoords.longitude
                ]
                
                print("🚀 MENGIRIM PAYLOAD: \(payloadDict)")
                let payloadData = try JSONSerialization.data(withJSONObject: payloadDict)
                
                let _ = try await shipmentRepo.createShipment(payload: payloadData)
                print("✅ BERHASIL MEMBUAT SHIPMENT BARU")
                
                DispatchQueue.main.async {
                    onComplete()
                }
            } catch {
                print("❌ GAGAL MEMBUAT SHIPMENT: \(error.localizedDescription)")
                print("❌ DETAIL ERROR: \(error)")
                
                DispatchQueue.main.async {
                    self.errorMessage = "Gagal membuat shipment: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func getCoordinates(from address: String) async throws -> CLLocationCoordinate2D {
        let placemarks = try await geocoder.geocodeAddressString(address)
        guard let location = placemarks.first?.location else {
            throw NSError(domain: "LocationError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Lokasi tidak ditemukan"])
        }
        return location.coordinate
    }
}
