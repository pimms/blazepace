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
                    Text("\(workoutType.rawValue)\n\(PaceFormatter.minuteString(fromSeconds: pace - delta)) - \(PaceFormatter.minuteString(fromSeconds: pace + delta))")
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
}

struct EditTargetPaceView: View {
    @Binding var pace: Int
    @Binding var delta: Int

    var body: some View {
        VStack {
            Text("Pace").bold()
            Stepper(value: $pace, in: 120...900, step: 5) {
                Text(PaceFormatter.minuteString(fromSeconds: pace))
                    .font(.title3)
            }

            Spacer(minLength: 12)

            Text("Delta").bold()
            Stepper(value: $delta, in: 1...30) {
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
