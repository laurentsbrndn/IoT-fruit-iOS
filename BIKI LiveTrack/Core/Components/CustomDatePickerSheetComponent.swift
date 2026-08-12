//
//  CustomDatePickerSheetComponent.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 12/08/26.


import SwiftUI

struct CustomDatePickerSheetComponent: View {
    @ObservedObject var viewModel: ShipmentHistoryViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                
                Text("Date and time - Pickers")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.theme.textSecondary)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                
                DatePicker("Date", selection: $viewModel.customStartDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding(.horizontal, 16)
                
                Divider()
                    .padding(.horizontal, 24)
                
                VStack(spacing: 16) {
                    DatePicker("Starts", selection: $viewModel.customStartDate, displayedComponents: .date)
                        .font(.system(size: 17, weight: .regular))
                    
                    DatePicker("Ends", selection: $viewModel.customEndDate, in: viewModel.customStartDate..., displayedComponents: .date)
                        .font(.system(size: 17, weight: .regular))
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .navigationTitle("Choose Dates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        viewModel.dateFilter = .custom
                        viewModel.currentPage = 1
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .bold))
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
