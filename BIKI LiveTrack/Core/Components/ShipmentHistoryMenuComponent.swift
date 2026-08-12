//
//  ShipmentHistoryMenuComponent.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 12/08/26.
//

import SwiftUI

struct ShipmentHistoryMenuComponent: View {
    @ObservedObject var viewModel: ShipmentHistoryViewModel
    
    var body: some View {
        Menu {
            // MARK: - Sort By Submenu
            Menu {
                Button(action: {
                    viewModel.sortOrder = .newestFirst
                    viewModel.currentPage = 1
                }) {
                    if viewModel.sortOrder == .newestFirst {
                        Label("Newest First", systemImage: "checkmark")
                    } else {
                        Text("Newest First")
                    }
                }
                
                Button(action: {
                    viewModel.sortOrder = .oldestFirst
                    viewModel.currentPage = 1
                }) {
                    if viewModel.sortOrder == .oldestFirst {
                        Label("Oldest First", systemImage: "checkmark")
                    } else {
                        Text("Oldest First")
                    }
                }
            } label: {
                Label("Sort By: \(viewModel.sortOrder.rawValue)", systemImage: "arrow.up.arrow.down")
            }
            
            // MARK: - Filter Date Submenu
            Menu {
                ForEach(DateFilterOption.allCases, id: \.self) { option in
                    Button(action: {
                        if option == .custom {
                            // Buka Sheet Date Picker
                            viewModel.isShowingCustomDatePicker = true
                        } else {
                            viewModel.dateFilter = option
                            viewModel.currentPage = 1
                        }
                    }) {
                        // Menangani tampilan label HIG dengan Checkmark / Chevron
                        if viewModel.dateFilter == option && option != .custom {
                            Label(option.rawValue, systemImage: "checkmark")
                        } else if option == .custom {
                            // SwiftUI tidak secara natural menampilkan chevron pada button dalam menu,
                            // namun kita masukkan agar sesuai standard bila didukung iOS bersangkutan
                            Label(option.rawValue, systemImage: "chevron.right")
                        } else {
                            Text(option.rawValue)
                        }
                    }
                }
            } label: {
                // Label dynamic yang menampilkan nama filter aktif
                Label("Filter Date: \(viewModel.dateFilter.rawValue)", systemImage: "calendar")
            }
            
            Divider()
            
            // MARK: - Export As CSV
            ShareLink(item: viewModel.generateCSVURL()) {
                Label("Export As CSV", systemImage: "clock") // Icon clock sesuai design yang Anda berikan
            }
            
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
                .frame(width: 44, height: 44)
                .background(Color.white)
                .clipShape(Circle())
        }
        // Melampirkan custom sheet di level Menu agar tidak mengganggu layout di luar
        .sheet(isPresented: $viewModel.isShowingCustomDatePicker) {
            CustomDatePickerSheetComponent(viewModel: viewModel)
                .presentationDetents([.height(550), .large]) // Memberikan height yang compact agar sesuai gambar
        }
    }
}
