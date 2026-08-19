import SwiftUI
import Charts

struct HistoricalLogGraphView: View {
    @ObservedObject var viewModel: ShipmentSummaryViewModel

    private var graphViewModel: HistoricalLogGraphViewModel {
        HistoricalLogGraphViewModel(
            summaryViewModel: viewModel
        )
    }

    var body: some View {
        VStack(spacing: 20) {
            HistoricalMetricChart(
                viewModel: graphViewModel.temperature,
                tint: Color.theme.primaryGreen
            )

            HistoricalMetricChart(
                viewModel: graphViewModel.humidity,
                tint: Color.theme.primaryGreen
            )
        }
    }
}

// MARK: - Chart UI

private struct HistoricalMetricChart: View {
    let viewModel: HistoricalLogGraphViewModel.Metric
    let tint: Color

    @State private var selectedTimestamp: Date?
    
    private let idealRangeColor =
        Color.theme.secondaryGreen
    
    private let warningColor =
        Color.theme.primaryYellow
    
    private var averageColor: Color {
        viewModel.averageIsIdeal
            ? tint
            : warningColor
    }

    private func pointColor(
        for reading: HistoricalMetricReading
    ) -> Color {
        viewModel.isIdeal(reading)
            ? tint
            : warningColor
    }

    private func lineColor(
        for segment:
            HistoricalLogGraphViewModel.LineSegment
    ) -> Color {
        segment.isIdeal
            ? tint
            : warningColor
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            chartHeader
            chart
        }
        .padding(20)
        .background(
            .white,
            in: RoundedRectangle(cornerRadius: 18)
        )
    }

    private var chartHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center, spacing: 12) {
                Text(viewModel.title)
                    .font(.app.bodyBold)

                Spacer()

                HStack(spacing: 8) {
                    Rectangle()
                        .fill(idealRangeColor)
                        .frame(
                            width: 32,
                            height: 14
                        )

                    Text("Ideal")
                        .font(.app.body)
                        .foregroundStyle(.secondary)
                }
            }

            Text(viewModel.averageText)
                .font(
                    .system(
                        size: 28,
                        weight: .semibold
                    )
                )
                .foregroundStyle(averageColor)
        }
    }

    private var chart: some View {
        Chart {
            idealRangeMark
            readingMarks
            selectedReadingMark
        }
        .chartYScale(domain: viewModel.yDomain)
        .chartXScale(
            domain: viewModel.chartStart...viewModel.chartEnd
        )
        .chartScrollableAxes(.horizontal)
        .chartXVisibleDomain(
            length: viewModel.visibleDuration
        )
        .chartXSelection(value: $selectedTimestamp)
        .chartXAxis {
            AxisMarks(values: .stride(by: .hour)) { axisValue in
                AxisGridLine(
                    stroke: StrokeStyle(
                        lineWidth: 0.5,
                        dash: [3, 3]
                    )
                )
                .foregroundStyle(.secondary.opacity(0.25))

                AxisTick()

                AxisValueLabel(centered: true) {
                    if let date = axisValue.as(Date.self) {
                        Text(
                            viewModel.hourText(for: date)
                        )
                    }
                }
                .foregroundStyle(.secondary)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) {
                AxisGridLine(
                    stroke: StrokeStyle(
                        lineWidth: 0.5,
                        dash: [3, 3]
                    )
                )
                .foregroundStyle(.secondary.opacity(0.25))

                AxisValueLabel()
                    .foregroundStyle(.secondary)
            }
        }
        .frame(height: 220)
    }

    @ChartContentBuilder
    private var idealRangeMark: some ChartContent {
        RectangleMark(
            xStart: .value(
                "Start",
                viewModel.chartStart
            ),
            xEnd: .value(
                "End",
                viewModel.chartEnd
            ),
            yStart: .value(
                "Ideal minimum",
                viewModel.idealRange.lowerBound
            ),
            yEnd: .value(
                "Ideal maximum",
                viewModel.idealRange.upperBound
            )
        )
        .foregroundStyle(idealRangeColor)
    }

    @ChartContentBuilder
    private var readingMarks: some ChartContent {
        lineSegmentMarks
        readingPointMarks
    }

    @ChartContentBuilder
    private var lineSegmentMarks: some ChartContent {
        ForEach(viewModel.lineSegments) { segment in
            LineMark(
                x: .value("Time", segment.start.timestamp),
                y: .value("Reading", segment.start.value),
                series: .value("Segment", segment.id)
            )
            .interpolationMethod(.linear)
            .lineStyle(
                StrokeStyle(
                    lineWidth: 2.5,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
            .foregroundStyle(lineColor(for: segment))

            LineMark(
                x: .value("Time", segment.end.timestamp),
                y: .value("Reading", segment.end.value),
                series: .value("Segment", segment.id)
            )
            .interpolationMethod(.linear)
            .lineStyle(
                StrokeStyle(
                    lineWidth: 2.5,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
            .foregroundStyle(lineColor(for: segment))
        }
    }

    @ChartContentBuilder
    private var readingPointMarks: some ChartContent {
        ForEach(viewModel.tenMinuteReadings) { reading in
            PointMark(
                x: .value("Time", reading.timestamp),
                y: .value("Reading", reading.value)
            )
            .symbolSize(24)
            .foregroundStyle(pointColor(for: reading))
        }
    }

    @ChartContentBuilder
    private var selectedReadingMark: some ChartContent {
        if let selectedReading {
            RuleMark(
                x: .value(
                    "Selected time",
                    selectedReading.timestamp
                )
            )
            .foregroundStyle(tint.opacity(0.45))
            .lineStyle(
                StrokeStyle(
                    lineWidth: 1,
                    dash: [4, 4]
                )
            )
            .annotation(position: .top) {
                selectedPointPopup(
                    for: selectedReading
                )
            }
        }
    }

    private var selectedReading: HistoricalMetricReading? {
        viewModel.selectedReading(
            nearestTo: selectedTimestamp
        )
    }

    private func selectedPointPopup(
        for reading: HistoricalMetricReading
    ) -> some View {
        VStack(spacing: 3) {
            Text(
                viewModel.timestampText(for: reading)
            )
            .font(.caption.weight(.semibold))

            Text(
                viewModel.valueText(for: reading)
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(8)
        .background(
            .white,
            in: RoundedRectangle(cornerRadius: 8)
        )
        .shadow(
            color: .black.opacity(0.12),
            radius: 4,
            y: 2
        )
    }
}

// MARK: - Preview

#if DEBUG
#Preview(
    "Historical Graph — Landscape",
    traits: .landscapeLeft
) {
    HistoricalLogGraphDatabasePreview()
}

@MainActor
private struct HistoricalLogGraphDatabasePreview: View {
    @StateObject private var previewViewModel =
        HistoricalLogGraphPreviewViewModel()

    var body: some View {
        Group {
            if let summaryViewModel =
                previewViewModel.summaryViewModel {
                ScrollView {
                    HistoricalLogGraphView(
                        viewModel: summaryViewModel
                    )
                    .padding(24)
                }
            } else if let errorMessage =
                previewViewModel.errorMessage {
                ContentUnavailableView(
                    "Could not load preview",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
            } else {
                ProgressView("Loading shipment data…")
            }
        }
        .background(Color.theme.tertiaryGreen)
        .frame(width: 1_024, height: 760)
        .task {
            await previewViewModel.load()
        }
    }
}
#endif
