//
//  ShipmentHistoryViewModel.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 11/08/26.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Enums
enum SortOrder: String {
    case newestFirst = "Newest First"
    case oldestFirst = "Oldest First"
}

enum DateFilterOption: String, CaseIterable {
    case today = "Today"
    case yesterday = "Yesterday"
    case last7Days = "Last 7 Days"
    case last30Days = "Last 30 Days"
    case last90Days = "Last 90 Days"
    case custom = "Choose Dates"
}

@MainActor
final class ShipmentHistoryViewModel: ObservableObject {
    @Published var completedShipments: [Shipment] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var lastUpdated: Date = Date()
    
    // MARK: - Search, Sort, Filter & Pagination Properties
    @Published var searchText: String = ""
    @Published var currentPage: Int = 1
    @Published var sortOrder: SortOrder = .newestFirst
    
    // Filter properties
    @Published var dateFilter: DateFilterOption = .last30Days // Default sesuai mockup awal
    @Published var customStartDate: Date = Date()
    @Published var customEndDate: Date = Date()
    @Published var isShowingCustomDatePicker: Bool = false
    
    let itemsPerPage: Int = 8
    
    private let shipmentRepository: ShipmentRepositoryProtocol
    
    init(shipmentRepository: ShipmentRepositoryProtocol = ShipmentRepository()) {
        self.shipmentRepository = shipmentRepository
    }
    
    // MARK: - Computed Properties
    var filteredShipments: [Shipment] {
        var filtered = completedShipments
        
        // 1. Filter Pencarian
        if !searchText.isEmpty {
            filtered = filtered.filter { shipment in
                let idString = "#\(shipment.id.uuidString.prefix(8).uppercased())"
                return idString.localizedCaseInsensitiveContains(searchText) ||
                       shipment.driver.name.localizedCaseInsensitiveContains(searchText) ||
                       shipment.truckPlateNumber.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // 2. Filter Waktu (Berdasarkan startDate)
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        
        filtered = filtered.filter { shipment in
            let shipDate = shipment.startDate
            
            switch dateFilter {
            case .today:
                return calendar.isDateInToday(shipDate)
            case .yesterday:
                return calendar.isDateInYesterday(shipDate)
            case .last7Days:
                guard let past = calendar.date(byAdding: .day, value: -7, to: startOfToday) else { return true }
                return shipDate >= past
            case .last30Days:
                guard let past = calendar.date(byAdding: .day, value: -30, to: startOfToday) else { return true }
                return shipDate >= past
            case .last90Days:
                guard let past = calendar.date(byAdding: .day, value: -90, to: startOfToday) else { return true }
                return shipDate >= past
            case .custom:
                let start = calendar.startOfDay(for: customStartDate)
                // Mengatur endDate ke penghujung hari (23:59:59)
                var components = DateComponents()
                components.day = 1
                components.second = -1
                guard let end = calendar.date(byAdding: components, to: calendar.startOfDay(for: customEndDate)) else { return true }
                
                return shipDate >= start && shipDate <= end
            }
        }
        
        // 3. Logika Pengurutan
        filtered.sort {
            if sortOrder == .newestFirst {
                return $0.startDate > $1.startDate
            } else {
                return $0.startDate < $1.startDate
            }
        }
        
        return filtered
    }
    
    var totalPages: Int {
        let count = filteredShipments.count
        return count == 0 ? 1 : (count + itemsPerPage - 1) / itemsPerPage
    }
    
    var paginatedShipments: [Shipment] {
        let startIndex = (currentPage - 1) * itemsPerPage
        let endIndex = min(startIndex + itemsPerPage, filteredShipments.count)
        guard startIndex < filteredShipments.count else { return [] }
        return Array(filteredShipments[startIndex..<endIndex])
    }
    
    var showingText: String {
        let total = filteredShipments.count
        if total == 0 { return "Showing 0 shipments" }
        let start = (currentPage - 1) * itemsPerPage + 1
        let end = min(currentPage * itemsPerPage, total)
        return "Showing \(start)–\(end) of \(total) shipments"
    }
    
    // MARK: - Methods
    func loadHistoryData() async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let allShipments = try await shipmentRepository.fetchAllShipments()
            self.completedShipments = allShipments.filter { $0.endDate != nil }
            self.lastUpdated = Date()
            self.currentPage = 1
        } catch {
            self.errorMessage = error.localizedDescription
            print("Gagal mengambil data riwayat shipments: \(error)")
        }
        
        self.isLoading = false
    }
    
    // MARK: - Export Logic
    func generateCSVURL() -> URL {
        var csvString = "Shipment ID,Origin,Destination,Plate Number,Driver Name,Shipment Date,Arrival Date\n"
        
        for shipment in filteredShipments {
            let id = "#\(shipment.id.uuidString.prefix(8).uppercased())"
            let origin = "\"\(shipment.startLatitude), \(shipment.startLongitude)\""
            let dest = "\"\(shipment.endLatitude ?? 0.0), \(shipment.endLongitude ?? 0.0)\""
            let plate = "\"\(shipment.truckPlateNumber)\""
            let driver = "\"\(shipment.driver.name)\""
            let sDate = "\"\(formatDate(shipment.startDate)) \(formatTime(shipment.startDate))\""
            let aDate = "\"\(formatDate(shipment.endDate ?? Date())) \(formatTime(shipment.endDate ?? Date()))\""
            
            let row = "\(id),\(origin),\(dest),\(plate),\(driver),\(sDate),\(aDate)\n"
            csvString.append(row)
        }
        
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent("ShipmentHistory_\(Date().timeIntervalSince1970).csv")
        
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Error creating CSV file: \(error)")
        }
        
        return fileURL
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: date)
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
