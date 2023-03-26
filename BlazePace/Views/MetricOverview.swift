import Foundation
import SwiftUI

struct MetricOverview: View {
    @ObservedObject var viewModel: WorkoutViewModel
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                SingleMetricView(
                    sfSymbolName: "speedometer",
                    value: currentPaceString,
                    subtitle: currentPaceSubtitle,
                    color: .black)
                .foregroundColor(.red)
                .background(content: {
                    if viewModel.isInTargetPace {
                        Color.green.ignoresSafeArea(.all).cornerRadius(5)
                        EmptyView()
                    } else {
                        Color.red.ignoresSafeArea(.all).cornerRadius(5)
                    }
                })
                SingleMetricView(
                    sfSymbolName: "heart.fill",
                    value: heartRateString,
                    subtitle: "HR",
                    color: .primary)
                SingleMetricView(
                    sfSymbolName: "road.lanes.curved.right",
                    value: distanceString,
                    subtitle: "km",
                    color: .primary)
            }
        }
        .overlay(alignment: .bottom, content: { pauseToast })
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
    let sfSymbolName: String
    let value: String?
    let subtitle: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: sfSymbolName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 24, maxHeight: 24)
            HStack(alignment: .lastTextBaseline) {
                Text(valueAsString)
                    .font(.title)
                Text(subtitle)
                    .font(.caption2.leading(.tight))
                    .fontWeight(.light)
                    .multilineTextAlignment(.leading)
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

struct MetricOverviewPreview: PreviewProvider {
    static func viewModel(target: Int, current: Int) -> WorkoutViewModel {
        let viewModel = WorkoutViewModel(workoutType: .running, targetPace: TargetPace(secondsPerKilometer: target, range: 10))
        viewModel.currentPace = Pace(secondsPerKilometer: current)
        viewModel.distance = Measurement(value: 7049, unit: .meters)
        viewModel.heartRate = 140
        viewModel.isActive = true
        return viewModel
    }

    static var previews: some View {
        Group {
            MetricOverview(viewModel: viewModel(target: 300, current: 300))
                .previewDisplayName("In range")
            MetricOverview(viewModel: viewModel(target: 300, current: 275))
                .previewDisplayName("Too fast")
            MetricOverview(viewModel: viewModel(target: 300, current: 315))
                .previewDisplayName("Too slow")
            MetricOverview(viewModel: WorkoutViewModel(workoutType: .running, targetPace: TargetPace(secondsPerKilometer: 300, range: 10)))
                .previewDisplayName("Empty")
        }
    }
}
