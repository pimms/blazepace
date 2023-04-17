import Foundation
import SwiftUI

struct SetupView: View {
    var onStart: (WorkoutStartData) -> Void

    @AppStorage(AppStorageKey.defaultPace)
    private var pace: Int = TargetPace.default.secondsPerKilometer
    @AppStorage(AppStorageKey.defaultPaceRange)
    private var delta: Int = TargetPace.default.range
    @State
    private var workoutType: WorkoutType
    @State
    private var hasStarted = false

    init(onStart: @escaping (WorkoutStartData) -> Void) {
        self.onStart = onStart
        _workoutType = .init(initialValue: WorkoutType.default)
    }

    var body: some View {
        if !hasStarted {
            ScrollView {
                VStack {
                    EditTargetPaceView(pace: $pace, delta: $delta)
                    Spacer(minLength: 12)
                    WorkoutTypeToggle(workoutType: $workoutType)

                    Spacer(minLength: 16)
                    Text(summaryString)
                        .multilineTextAlignment(.center)
                    Spacer(minLength: 12)
                    Text("You can change the target pace in the middle of the workout.")
                        .multilineTextAlignment(.center)
                    Spacer(minLength: 12)

                    Button(action: { startButtonClicked() }) {
                        Text("🔥 Start! 🔥")
                    }
                }
            }
            .navigationTitle("Setup")
        } else {
            SpinnerView(text: "Starting")
        }
    }

    private func startButtonClicked() {
        hasStarted = true
        UserDefaults.standard.set(workoutType.rawValue, forKey: AppStorageKey.defaultWorkoutType)
        let targetPace = TargetPace(secondsPerKilometer: pace, range: delta)
        let startData = WorkoutStartData(workoutType: workoutType, targetPace: targetPace)
        onStart(startData)
    }

    private var summaryString: String {
        let lowPace = PaceFormatter.paceString(fromSecondsPerKilometer: pace - delta)
        let highPace = PaceFormatter.paceString(fromSecondsPerKilometer: pace + delta)

        let speedUnit: String

        // Start with km/h, adulterate to mph if needed
        var lowSpeed = 3600.0 / Double(pace + delta)
        var highSpeed = 3600.0 / Double(pace - delta)

        switch MeasurementSystem.current {
        case .metric:
            speedUnit = "km/h"
        case .freedomUnits🇺🇸🔫:
            lowSpeed /= 1.609344
            highSpeed /= 1.609344
            speedUnit = "mph"
        }

        return "\(workoutType.rawValue)\n" +
            "\(lowPace) - \(highPace)\n" +
            "\(String(format: "%0.1f", lowSpeed)) - \(String(format: "%.1f", highSpeed)) \(speedUnit)"
    }
}

struct EditTargetPaceView: View {
    @Binding var pace: Int
    @Binding var delta: Int

    var body: some View {
        VStack {
            Text("Pace").bold()
            Stepper(value: $pace, in: 120...900, step: 5) {
                Text(PaceFormatter.paceString(fromSecondsPerKilometer: pace))
                    .font(.title3)
            }

            Spacer(minLength: 12)

            Text("Range").bold()
            Stepper(value: $delta, in: 1...45) {
                Text("± \(delta)s").font(.title3)
            }
        }
    }
}

struct ConfigViewPreviews: PreviewProvider {
    static var previews: some View {
        SetupView(onStart: { _ in })
    }
}
