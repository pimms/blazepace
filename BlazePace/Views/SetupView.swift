import Foundation
import SwiftUI

struct SetupView: View {
    var onStart: (WorkoutStartData) -> Void

    @AppStorage(AppStorageKey.defaultPace)
    private var pace: Int = 300
    @AppStorage(AppStorageKey.defaultPaceRange)
    private var delta: Int = 10
    @State
    private var workoutType: WorkoutType = .running

    var body: some View {
        ScrollView {
            VStack {
                Text("Pace").frame(maxWidth: .infinity, alignment: .leading)
                Stepper(value: $pace, in: 120...800, step: 5) {
                    Text(PaceFormatter.minuteString(fromSeconds: pace))
                        .font(.title3)
                }
                
                Text("Delta").frame(maxWidth: .infinity, alignment: .leading)
                Stepper(value: $delta, in: 1...30) {
                    Text("± \(delta)s").font(.title3)
                }

                WorkoutTypeToggle(workoutType: $workoutType)

                Spacer(minLength: 16)
                Text("\(workoutType.rawValue)\n\(PaceFormatter.minuteString(fromSeconds: pace - delta)) - \(PaceFormatter.minuteString(fromSeconds: pace + delta))")
                    .multilineTextAlignment(.center)
                Spacer(minLength: 12)

                Button(action: { startButtonClicked() }) {
                    Text("Start")
                }
            }
        }
        .navigationTitle("Setup")
    }

    private func startButtonClicked() {
        let targetPace = TargetPace(secondsPerKilometer: pace, range: delta)
        let startData = WorkoutStartData(workoutType: workoutType, targetPace: targetPace)
        onStart(startData)
    }
}

struct ConfigViewPreviews: PreviewProvider {
    static var previews: some View {
        SetupView(onStart: { _ in })
    }
}
