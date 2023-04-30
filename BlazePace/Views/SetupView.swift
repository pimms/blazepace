import Foundation
import SwiftUI

struct SetupView: View {
    var onStart: (WorkoutStartData) async -> Bool

    @AppStorage(AppStorageKey.defaultPace)
    private var pace: Int = TargetPace.default.secondsPerKilometer
    @AppStorage(AppStorageKey.defaultPaceRange)
    private var delta: Int = TargetPace.default.range
    @State private var workoutType: WorkoutType
    @State private var hasStarted = false
    @State private var presentStartError = false
    @State private var airplayConnected = false

    init(onStart: @escaping (WorkoutStartData) async -> Bool) {
        self.onStart = onStart
        _workoutType = .init(initialValue: WorkoutType.default)
    }

    var body: some View {
        if !hasStarted {
            ScrollView {
                VStack(spacing: 12) {
                    EditTargetPaceView(pace: $pace, delta: $delta)
                    WorkoutTypeToggle(workoutType: $workoutType)

                    Text(summaryString)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                    Text("You can change the target pace in the middle of the workout by rotating the digital crown.")
                        .multilineTextAlignment(.center)

                    if !airplayConnected {
                        VStack(spacing: 8) {
                            Text("No headphones")
                                .font(.title3)
                                .bold()
                                .multilineTextAlignment(.center)
                            Text("It seems like you have no headphones connected to the watch. You may not notice the pace alerts.")
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(Color.yellow)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                        .padding(.bottom, 4)
                    }

                    Button(action: { startButtonClicked() }) {
                        Text("Start")
                    }
                }
            }
            .alert(isPresented: $presentStartError) {
                Alert(
                    title: Text("Failed to start workout"),
                    message: Text("Did you not grant HealthKit permissions? These can be reviewed in the Settings app on your watch."))
            }
            .onAppear {
                airplayConnected = AVHelper.airPlayConnected()
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

        Task {
            if await !onStart(startData) {
                hasStarted = false
                presentStartError = true
            }
        }
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
            Stepper(value: $pace, in: TargetPace.minValue...TargetPace.maxValue, step: TargetPace.paceIncrement) {
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
        SetupView(onStart: { _ in false })
    }
}
