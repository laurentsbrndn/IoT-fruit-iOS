import SwiftUI

enum TimeEditType {
    case start
    case end

    var title: String {
        switch self {
        case .start:
            return "Adjust Start Date & Time"

        case .end:
            return "Adjust End Date & Time"
        }
    }
}

struct EditTimeSheetComponent: View {
    @Environment(\.dismiss) private var dismiss

    let editType: TimeEditType
    let originalDate: Date
    let counterpartDate: Date
    let onSave: (Date) -> Void

    @State private var adjustedDate: Date

    init(
        editType: TimeEditType,
        initialDate: Date,
        counterpartDate: Date,
        onSave: @escaping (Date) -> Void
    ) {
        self.editType = editType
        self.originalDate = initialDate
        self.counterpartDate = counterpartDate
        self.onSave = onSave

        _adjustedDate = State(
            initialValue: initialDate
        )
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                header

                dateComparisonSection

                calendarSection
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
        )
        .presentationBackground(
            Color(uiColor: .systemBackground)
        )
        .presentationDetents([.fraction(0.85)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            Text(editType.title)
                .font(.app.bodyBold)

            HStack {
                Button("Close", systemImage: "xmark") {
                    dismiss()
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.bordered)
                .buttonBorderShape(.circle)
                .controlSize(.large)
                .foregroundStyle(.primary)
                .accessibilityLabel("Close")

                Spacer()

                Button("Adjust") {
                    onSave(adjustedDate)
                    dismiss()
                }
                .font(.app.bodyBold)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.blue)
                .accessibilityLabel("Save adjusted date and time")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
    }

    // MARK: - Original and Adjusted

    private var dateComparisonSection: some View {
        VStack(spacing: 0) {
            originalDateRow

            Divider()
                .overlay(Color(uiColor: .separator))
                .padding(.horizontal, 16)

            adjustedDateRow
        }
        .background(
            Color(uiColor: .secondarySystemBackground)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
        )
    }

    private var originalDateRow: some View {
        HStack(spacing: 16) {
            Text("Original")
                .font(.app.body)
                .foregroundStyle(.primary)

            Spacer()

            Text(formattedDate(originalDate))
                .font(.app.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 52)
    }

    private var adjustedDateRow: some View {
        HStack(spacing: 16) {
            Text("Adjusted")
                .font(.app.body)
                .foregroundStyle(.primary)

            Spacer()

            Text(formattedDate(adjustedDate))
                .font(.app.body)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 52)
    }

    // MARK: - Apple Calendar

    private var calendarSection: some View {
        DatePicker(
            "Adjusted date and time",
            selection: $adjustedDate,
            in: allowedDates,
            displayedComponents: [
                .date,
                .hourAndMinute
            ]
        )
        .datePickerStyle(.graphical)
        .labelsHidden()
        .tint(Color.theme.primaryGreen)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helpers

    private func formattedDate(_ date: Date) -> String {
        date.formatted(
            date: .abbreviated,
            time: .standard
        )
    }

    private var allowedDates: ClosedRange<Date> {
        let lowerDate: Date
        let upperDate: Date

        switch editType {
        case .start:
            lowerDate = Date.distantPast
            upperDate = counterpartDate

        case .end:
            lowerDate = counterpartDate
            upperDate = Date.distantFuture
        }

        return lowerDate...upperDate
    }
}
