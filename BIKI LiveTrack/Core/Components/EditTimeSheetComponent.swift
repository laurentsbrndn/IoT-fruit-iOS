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
    var onSave: (Date) -> Void
    
    @State private var selectedDate: Date
    
    init(editType: TimeEditType, initialDate: Date, onSave: @escaping (Date) -> Void) {
        self.editType = editType
        self._selectedDate = State(initialValue: initialDate)
        self.onSave = onSave
    }
    
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
                        onSave(selectedDate)
                        dismiss()
                    }
                }
            }
        }
    }
}
