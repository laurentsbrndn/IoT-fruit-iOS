import Foundation
import Combine

@MainActor
final class ShipmentDateTimeAdjustmentViewModel: ObservableObject {

    // MARK: - Values displayed by the View

    let sheetTitle: String
    let originalDate: Date
    let allowedDates: ClosedRange<Date>

    // The DatePicker changes this value.
    @Published var adjustedDate: Date

    // Controls the loading indicator in the Adjust button.
    @Published private(set) var isSaving = false

    // Displayed when saving fails.
    @Published private(set) var errorMessage: String?

    // Tells the View that saving succeeded and it may close.
    @Published private(set) var didSave = false

    // MARK: - Dependencies

    private let editType: TimeEditType
    private let shipmentSummaryViewModel: ShipmentSummaryViewModel

    // MARK: - Initializer

    init(
        shipmentSummaryViewModel: ShipmentSummaryViewModel,
        editType: TimeEditType
    ) {
        self.shipmentSummaryViewModel = shipmentSummaryViewModel
        self.editType = editType

        let initialDate: Date
        let dateRange: ClosedRange<Date>
        let title: String

        switch editType {
        case .start:
            initialDate =
                shipmentSummaryViewModel.shipment.startDate

            dateRange =
                Date.distantPast
                ...
                (
                    shipmentSummaryViewModel.effectiveTripEndDate
                    ?? Date.distantFuture
                )

            title = "Adjust Start Date & Time"

        case .end:
            initialDate =
                shipmentSummaryViewModel.shipment.endDate
                ?? shipmentSummaryViewModel.effectiveTripEndDate
                ?? shipmentSummaryViewModel.shipment.startDate

            dateRange =
                shipmentSummaryViewModel.effectiveTripStartDate
                ...
                Date.distantFuture

            title = "Adjust End Date & Time"
        }

        self.originalDate = initialDate
        self.adjustedDate = initialDate
        self.allowedDates = dateRange
        self.sheetTitle = title
    }

    // MARK: - Text formatting

    var originalDateText: String {
        formatDate(originalDate)
    }

    var adjustedDateText: String {
        formatDate(adjustedDate)
    }

    private func formatDate(_ date: Date) -> String {
        date.formatted(
            date: .abbreviated,
            time: .standard
        )
    }

    // MARK: - Save

    func saveAdjustment() async {
        guard !isSaving else {
            return
        }

        isSaving = true
        errorMessage = nil
        didSave = false

        let wasSaved =
            await shipmentSummaryViewModel.updateShipmentTime(
                adjustedDate,
                editType: editType
            )

        if wasSaved {
            didSave = true
        } else {
            errorMessage =
                shipmentSummaryViewModel.shipmentTimeUpdateError
                ?? "The adjusted date and time could not be saved."
        }

        isSaving = false
    }
}
