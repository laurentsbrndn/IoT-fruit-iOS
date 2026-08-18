//
//  ShipmentHistoryRowComponent.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 10/08/26.
//

import SwiftUI

struct ShipmentHistoryRowComponent: View {
    var shipmentID: String
    
    var startLatitude: Double
    var startLongitude: Double
    var endLatitude: Double
    var endLongitude: Double
    
    var truckPlate: String
    var driverName: String
    
    var shipmentDate: String
    var shipmentTime: String
    var arrivalDate: String
    var arrivalTime: String
    var statusColor: Color
    var rowBackgroundColor: Color
    
    var rawStartDate: Date
    var rawEndDate: Date
    
    var onSaveTime: (Date, TimeEditType) -> Void
    
    @State private var showingEditTimeSheet = false
    @State private var selectedEditType: TimeEditType = .start
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Text(shipmentID)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color.theme.primaryGreen)
                .frame(width: 110, alignment: .leading)
            
            LocationLabelComponent(latitude: startLatitude, longitude: startLongitude)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LocationLabelComponent(latitude: endLatitude, longitude: endLongitude)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(truckPlate)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color.theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(driverName)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color.theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(shipmentDate)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color.theme.textPrimary)
                
                Text(shipmentTime)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color.theme.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(arrivalDate)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color.theme.textPrimary)
                
                Text(arrivalTime)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color.theme.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Menu {
                Button {
                    selectedEditType = .start
                    showingEditTimeSheet = true
                } label: {
                    Label(
                        "Adjust Start Date & Time",
                        systemImage: "calendar.badge.clock"
                    )
                }

                Button {
                    selectedEditType = .end
                    showingEditTimeSheet = true
                } label: {
                    Label(
                        "Adjust End Date & Time",
                        systemImage: "calendar.badge.clock"
                    )
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Shipment options")
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .background(rowBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .sheet(isPresented: $showingEditTimeSheet) {
            EditTimeSheetComponent(
                editType: selectedEditType,
                initialDate:
                    selectedEditType == .start
                    ? rawStartDate
                    : rawEndDate,
                counterpartDate:
                    selectedEditType == .start
                    ? rawEndDate
                    : rawStartDate,
                onSave: { newDate in
                    onSaveTime(
                        newDate,
                        selectedEditType
                    )
                }
            )
        }
    }
}
