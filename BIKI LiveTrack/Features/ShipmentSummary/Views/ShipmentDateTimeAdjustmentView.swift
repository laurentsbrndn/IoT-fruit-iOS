import SwiftUI

@MainActor
struct ShipmentDateTimeAdjustmentSheet: View {

    // This View owns its sheet-specific ViewModel.
    @StateObject private var sheetViewModel:
        ShipmentDateTimeAdjustmentViewModel

    // Closing a sheet is UI navigation, so this belongs in the View.
    @Environment(\.dismiss) private var dismiss

    // This initializer keeps your existing ShipmentSummaryView code working.
    init(
        viewModel: ShipmentSummaryViewModel,
        editType: TimeEditType
    ) {
        _sheetViewModel = StateObject(
            wrappedValue: ShipmentDateTimeAdjustmentViewModel(
                shipmentSummaryViewModel: viewModel,
                editType: editType
            )
        )
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                header
                dateComparisonSection
                calendarSection
                errorMessage
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
        }
        .presentationBackground(
            Color(uiColor: .systemBackground)
        )
        .presentationDetents([.fraction(0.85)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
        .onChange(of: sheetViewModel.didSave) {
            if sheetViewModel.didSave {
                dismiss()
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            Text(sheetViewModel.sheetTitle)
                .font(.app.bodyBold)

            HStack {
                closeButton

                Spacer()

                adjustButton
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
    }

    private var closeButton: some View {
        Button("Close", systemImage: "xmark") {
            dismiss()
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.bordered)
        .buttonBorderShape(.circle)
        .controlSize(.large)
        .foregroundStyle(.primary)
        .accessibilityLabel("Close")
    }

    private var adjustButton: some View {
        Button {
            Task {
                await sheetViewModel.saveAdjustment()
            }
        } label: {
            if sheetViewModel.isSaving {
                ProgressView()
            } else {
                Text("Adjust")
                    .font(.app.bodyBold)
            }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(.blue)
        .disabled(sheetViewModel.isSaving)
        .accessibilityLabel("Save adjusted date and time")
    }

    // MARK: - Original and Adjusted Dates

    private var dateComparisonSection: some View {
        VStack(spacing: 0) {
            dateRow(
                title: "Original",
                dateText: sheetViewModel.originalDateText,
                dateColor: .secondary
            )

            Divider()
                .overlay(Color(uiColor: .separator))
                .padding(.horizontal, 16)

            dateRow(
                title: "Adjusted",
                dateText: sheetViewModel.adjustedDateText,
                dateColor: .primary
            )
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

    private func dateRow(
        title: String,
        dateText: String,
        dateColor: Color
    ) -> some View {
        HStack(spacing: 16) {
            Text(title)
                .font(.app.body)
                .foregroundStyle(.primary)

            Spacer()

            Text(dateText)
                .font(.app.body)
                .foregroundStyle(dateColor)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 52)
    }

    // MARK: - Calendar

    private var calendarSection: some View {
        DatePicker(
            "Adjusted date and time",
            selection: $sheetViewModel.adjustedDate,
            in: sheetViewModel.allowedDates,
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

    // MARK: - Error Message

    @ViewBuilder
    private var errorMessage: some View {
        if let message = sheetViewModel.errorMessage {
            Text(message)
                .font(.app.body)
                .foregroundStyle(Color.theme.primaryRed)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
        }
    }
}
