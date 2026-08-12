//
//  EditTimeSheetComponent.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 11/08/26.
//

import SwiftUI

enum TimeEditType {
    case start
    case end
    
    var title: String {
        switch self {
        case .start: return "Edit Start Time"
        case .end: return "Edit End Time"
        }
    }
}

struct EditTimeSheetComponent: View {
    @Environment(\.dismiss) var dismiss
    var editType: TimeEditType
    
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Select Date & Time",
                    selection: $selectedDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .padding()
                
                Spacer()
            }
            .navigationTitle(editType.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // panggil viewmodel buat nyimpen data ke api
                        print("Tanggal disimpan: \(selectedDate)")
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview(traits: .landscapeLeft) {
    EditTimeSheetComponent(editType: .start)
}
