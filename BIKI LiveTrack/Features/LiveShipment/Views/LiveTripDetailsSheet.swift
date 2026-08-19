//
//  LiveTripDetailsSheet.swift
//  BIKI LiveTrack
//
//  Created by Joana Mardas on 18/08/26.

import SwiftUI
import MapKit

struct LiveTripDetailsSheet: View {
    @ObservedObject var viewModel: LiveShipmentViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                header
                mapSection
                locationCards
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .presentationDetents([.fraction(0.85)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
        .task {
            // Panggil API Geocoder dan MKDirections secara bersamaan
            async let fetchNames: () = viewModel.loadLiveLocationNames()
            async let fetchRoute: () = viewModel.fetchExpectedRoute()
            _ = await (fetchNames, fetchRoute)
        }
    }
    
    // MARK: - Header
    private var header: some View {
        HStack {
            Spacer()
            Text("Trip Details")
                .font(.app.bodyBold)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .overlay(alignment: .trailing) {
            Button("Close", systemImage: "xmark") {
                dismiss()
            }
            .labelStyle(.iconOnly)
            .foregroundStyle(.secondary)
            .accessibilityLabel("Close live trip details")
        }
        .padding(.top, 24)
    }
    
    // MARK: - Map
    private var mapSection: some View {
        ZStack(alignment: .top) {
            // NATIVE IOS 17 MAP
            Map {
                Marker("Start Point", coordinate: viewModel.startCoordinate)
                    .tint(.blue)
                
                if let endCoord = viewModel.endCoordinate {
                    Marker("Destination", coordinate: endCoord)
                        .tint(.red)
                }
                
                // GARIS HIJAU (Sensor Logs / Masa Lalu)
                MapPolyline(coordinates: viewModel.traveledCoordinates)
                    .stroke(Color.theme.primaryGreen, lineWidth: 6)
                
                // GARIS PUTUS-PUTUS (Apple Maps / Masa Depan)
                if let route = viewModel.expectedRoute {
                    MapPolyline(route)
                        .stroke(Color.gray, style: StrokeStyle(lineWidth: 4, dash: [8, 8]))
                }
                
                // CURRENT LOCATION BUBBLE (Truk)
                Annotation(coordinate: viewModel.currentRouteCoordinate) {
                    VStack(spacing: 4) {
                        VStack(spacing: 2) {
                            Text("Current Location")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.primary)
                            Text(viewModel.currentLocationName)
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                        
                        Image(systemName: "box.truck.fill")
                            .padding(8)
                            .background(Color.theme.primaryGreen)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                } label: {
                    Text("Current")
                }
            }
            TimelineView(.periodic(from: .now, by: 1)) { context in
                durationCard(asOf: context.date)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.top, 18)
        }
        .frame(minHeight: 350)
    }
    
    // MARK: - Duration
    private func durationCard(asOf date: Date) -> some View {
        VStack(spacing: 4) {
            Text("Trip Duration")
                .font(.system(size: 20))
            
            Text(viewModel.tripDuration(asOf: date))
                .font(.system(size: 34))
                .monospacedDigit()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .frame(width: 214, height: 92)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 15, style: .continuous)
        )
        .shadow(color: .black.opacity(0.1), radius: 4, y: 4)
    }
    
    // MARK: - Location Cards (Diubah ke Start & End)
    private var locationCards: some View {
        HStack(alignment: .top, spacing: 18) {
            LiveLocationSummaryCard(
                title: "Start Location",
                timeText: viewModel.shipment.startDate.toReadableString(),
                locationName: viewModel.startLocationName
            )
            
            LiveLocationSummaryCard(
                title: "End Location",
                timeText: "In progress", // Sesuai instruksi, End Date belum ada
                locationName: viewModel.endLocationName
            )
        }
    }
}

// MARK: - Location Summary Card
private struct LiveLocationSummaryCard: View {
    let title: String
    let timeText: String // Menggunakan String agar fleksibel menerima "In progress"
    let locationName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.theme.primaryGreen)
            
            HStack(alignment: .top, spacing: 16) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.theme.primaryGreen)
                
                Text(timeText)
                    .font(.app.body)
                    .foregroundStyle(Color.theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            HStack(alignment: .top, spacing: 16) {
                Image(systemName: "mappin")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.theme.primaryGreen)
                
                Text(locationName)
                    .font(.app.body)
                    .foregroundStyle(Color.theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 160, alignment: .leading)
        .padding(24)
        .background(Color.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 4, y: 4)
    }
}
