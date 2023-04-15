import Foundation
import SwiftUI

struct MetricOverview: View {
    @ObservedObject var viewModel: WorkoutViewModel

    var body: some View {
        TimelineView(PeriodicTimelineSchedule(from: viewModel.startDate, by: 1)) { _ in
            metricsView()
        }
        .overlay(alignment: .bottom, content: { pauseToast })
    }

    @ViewBuilder
    private func metricsView() -> some View {
        if let paceAlert = viewModel.currentPaceAlert {
            paceAlertView(for: paceAlert)
        } else {
            defaultMetricsView()
        }
    }

    private func paceAlertView(for alert: WorkoutViewModel.PaceAlert) -> some View {
        VStack {
            Text(currentPaceString)
                .font(Font.system(size: 69))
                .allowsTightening(true)

            switch alert {
            case .tooFastAlert:
                Text("TOO FAST")
                    .font(.title)
            case.tooSlowAlert:
                Text("TOO SLOW")
                    .font(.title)
            }
        }
        .font(.title)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(Color.red)
    }

    private func defaultMetricsView() -> some View {
        VStack(spacing: 0) {
            SingleMetricView(
                sfSymbolName: "speedometer",
                value: currentPaceString,
                subtitle: currentPaceSubtitle,
                color: .white)
            .fontWeight(viewModel.isInTargetPace ? .regular : .semibold)
            .background(content: {
                if viewModel.isInTargetPace {
                    Color.clear.ignoresSafeArea(.all).cornerRadius(5)
                    EmptyView()
                } else {
                    Color.red.ignoresSafeArea(.all).cornerRadius(5)
                }
            })

            SingleMetricView(
                sfSymbolName: "stopwatch",
                value: "\(PaceFormatter.durationString(from: Int(Date().timeIntervalSince(viewModel.startDate))))",
                subtitle: nil,
                color: viewModel.isInTargetPace ? .yellow : .primary)

            SingleMetricView(
                sfSymbolName: "heart.fill",
                value: heartRateString,
                subtitle: "HR",
                color: viewModel.isInTargetPace ? .red : .primary)
            SingleMetricView(
                sfSymbolName: "road.lanes.curved.left",
                value: distanceString,
                subtitle: "km",
                color: viewModel.isInTargetPace ? .green : .primary)
        }
        .scenePadding()
        .dynamicTypeSize(.medium)
    }

    @ViewBuilder
    private var pauseToast: some View {
        if !viewModel.isActive {
            Text("Workout paused")
                .ignoresSafeArea(.all)
                .frame(maxWidth: .infinity)
                .background(Color.yellow)
                .foregroundColor(.black)
        } else {
            EmptyView()
        }
    }

    private var heartRateString: String {
        if let heartRate = viewModel.heartRate {
            return "\(heartRate)"
        } else {
            return "—"
        }
    }

    private var currentPaceString: String {
        if let pace = viewModel.currentPace {
            return PaceFormatter.minuteString(fromSeconds: pace.secondsPerKilometer)
        } else {
            return "—"
        }
    }

    private var currentPaceSubtitle: String {
        switch viewModel.paceRelativeToTarget {
        case .tooSlow:
            return "TOO\nSLOW"
        case .inRange:
            return ""
        case .tooFast:
            return "TOO\nFAST"
        }
    }

    private var distanceString: String {
        if var distance = viewModel.distance {
            if distance.unit != .kilometers {
                distance.convert(to: .kilometers)
            }

            return String(format: "%.2f", distance.value)
        } else {
            return "—"
        }
    }
}

private struct SingleMetricView: View {
    let sfSymbolName: String?
    let value: String?
    let subtitle: String?
    let color: Color

    var body: some View {
        HStack {
            if let sfSymbolName {
                Image(systemName: sfSymbolName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 24, maxHeight: 24)
            }
            HStack(alignment: .lastTextBaseline) {
                Text(valueAsString)
                    .font(.largeTitle)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption2.leading(.tight))
                        .fontWeight(.light)
                        .multilineTextAlignment(.leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal)
        .foregroundColor(color)
    }

    var valueAsString: String {
        if let value {
            return "\(value)"
        } else {
            return ""
        }
    }
}

/// Thanks to WWDC21, "Build a workout app for Apple watch"
private class ElapsedTimeFormatter: Formatter {
    let componentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    var showSubseconds = true

    override func string(for value: Any?) -> String? {
        guard let time = value as? TimeInterval else {
            return nil
        }

        guard let formattedString = componentsFormatter.string(from: time) else {
            return nil
        }

        if showSubseconds {
            let hundredths = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
            let decimalSeparator = Locale.current.decimalSeparator ?? "."
            return String(format: "%@%@%0.2d", formattedString, decimalSeparator, hundredths)
        }

        return formattedString
    }
}

struct MetricOverviewPreview: PreviewProvider {
    static func viewModel(target: Int, current: Int, alert: WorkoutViewModel.PaceAlert?) -> WorkoutViewModel {
        let viewModel = WorkoutViewModel(
            workoutType: .running,
            startDate: Date(),
            targetPace: TargetPace(secondsPerKilometer: target, range: 10))
        viewModel.currentPace = Pace(secondsPerKilometer: current)
        viewModel.distance = Measurement(value: 7049, unit: .meters)
        viewModel.heartRate = 140
        viewModel.isActive = true

        switch alert {
        case .tooFastAlert:
            viewModel.recentRollingAveragePace = Pace(secondsPerKilometer: target - 30)
        case .tooSlowAlert:
            viewModel.recentRollingAveragePace = Pace(secondsPerKilometer: target + 30)
        case nil:
            break
        }

        return viewModel
    }

    static var previews: some View {
        Group {
            MetricOverview(viewModel: viewModel(target: 300, current: 300, alert: nil))
                .previewDisplayName("In range")
            MetricOverview(viewModel: viewModel(target: 300, current: 275, alert: nil))
                .previewDisplayName("Too fast")
            MetricOverview(viewModel: viewModel(target: 300, current: 315, alert: nil))
                .previewDisplayName("Too slow")
            MetricOverview(viewModel: viewModel(target: 300, current: 315, alert: .tooFastAlert))
                .previewDisplayName("Too fast (alert)")
            MetricOverview(viewModel: viewModel(target: 300, current: 829, alert: .tooSlowAlert))
                .previewDisplayName("Too slow (alert)")
            MetricOverview(viewModel: WorkoutViewModel(workoutType: .running,
                                                       startDate: Date(),
                                                       targetPace: TargetPace(secondsPerKilometer: 300, range: 10)))
                .previewDisplayName("Empty")
        }
    }
}
