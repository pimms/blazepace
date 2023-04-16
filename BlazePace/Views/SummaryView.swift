import Foundation
import SwiftUI

struct SummaryView: View {
    let summary: WorkoutSummary
    @Binding var navigationStack: [Navigation]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text(summary.workoutType.rawValue)
                    .font(.title3).fontWeight(.light)
                    .frame(maxWidth: .infinity, alignment: .leading)

                StringSummary(
                    title: "Target pace",
                    value: "\(PaceFormatter.paceString(fromSecondsPerKilometer: summary.targetPace.lowerBound)) - \(PaceFormatter.paceString(fromSecondsPerKilometer: summary.targetPace.upperBound))")
                StringSummary(
                    title: "Average pace",
                    value: PaceFormatter.paceString(fromSecondsPerKilometer: summary.averagePace.secondsPerKilometer))
                StringSummary(
                    title: "Distance",
                    value: distanceString)
                StringSummary(
                    title: "Elapsed time",
                    value: PaceFormatter.durationString(from: Int(summary.elapsedTime)))

                Spacer()

                Button(action: { navigationStack = [] }) {
                    Text("Done").bold()
                }
                .background(Color.green.cornerRadius(8))
                .foregroundColor(.black)
            }
        }
        .navigationTitle("Summary")
    }

    private var distanceString: String {
        switch MeasurementSystem.current {
        case .metric:
            return String(format: "%.2f km", summary.distance.converted(to: .kilometers).value)
        case .freedomUnits🇺🇸🔫:
            return String(format: "%.2f mi", summary.distance.converted(to: .miles).value)
        }
    }
}

private struct StringSummary: View {
    let title: String
    let value: String

    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(value)
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct SummaryViewPreview: PreviewProvider {
    static let summary = WorkoutSummary(
        workoutType: .running,
        distance: Measurement(value: 10483, unit: .meters),
        elapsedTime: 3601,
        averagePace: Pace(secondsPerKilometer: 300),
        targetPace: TargetPace(secondsPerKilometer: 300, range: 10))

    static var previews: some View {
        SummaryView(summary: summary, navigationStack: .constant([]))
    }
}
