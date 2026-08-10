//
//  LocationLabelComponent.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 10/08/26.
//

import SwiftUI
import CoreLocation

struct LocationLabelComponent: View {
    let latitude: Double
    let longitude: Double
    
    @State private var locationName: String = "Loading location..."
    
    var body: some View {
        Text(locationName)
            .font(.system(size: 14, weight: .regular))
            .foregroundColor(Color.theme.textSecondary)
            .task {
                await fetchLocationName()
            }
    }
    
    private func fetchLocationName() async {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let place = placemarks.first {
                let name = place.name ?? ""
                let locality = place.locality ?? place.subAdministrativeArea ?? ""
                
                if !name.isEmpty && !locality.isEmpty {
                    self.locationName = "\(name), \(locality)"
                } else if !name.isEmpty {
                    self.locationName = name
                } else if !locality.isEmpty {
                    self.locationName = locality
                } else {
                    self.locationName = "Lat: \(latitude), Lon: \(longitude)"
                }
            } else {
                self.locationName = "Unknown Location"
            }
        } catch {
            self.locationName = "Lat: \(String(format: "%.4f", latitude)), Lon: \(String(format: "%.4f", longitude))"
        }
    }
}

#Preview {
    ZStack {
        Color.theme.background.ignoresSafeArea()
        
        VStack(spacing: 16) {
            LocationLabelComponent(latitude: -6.1754, longitude: 106.8272)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
            
            LocationLabelComponent(latitude: -6.2000, longitude: 106.8167)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
        }
        .padding()
    }
}
