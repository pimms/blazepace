import Foundation
import SwiftUI

struct SettingsView: View {
    enum Context: Hashable {
        case workoutNotActive
        case workoutActive
    }

    let context: Context

    @AppStorage(AppStorageKey.paceAlertInterval)
    private var paceNotificationInterval: TimeInterval = 5
    @AppStorage(AppStorageKey.duckOthersOnAlert)
    private var duckOthersOnAlert = true

    @State private var paceAlertType: PaceAlertType
    @State private var measurementSystem: MeasurementSystem
    @State private var demoAlertPlayer: AlertPlayer?

    init(context: Context) {
        self.context = context
        let alertString = UserDefaults.standard.string(forKey: AppStorageKey.paceAlertType) ?? ""
        _paceAlertType = .init(initialValue: PaceAlertType(rawValue: alertString) ?? .beep)
        _measurementSystem = .init(initialValue: MeasurementSystem.current)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Alert interval
                VStack {
                    Text("Alert interval")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    Spacer()
                    Stepper(value: $paceNotificationInterval, in: 2...10, step: 0.25) {
                        Text(String(format: "%.2f s", paceNotificationInterval))
                            .font(.body)
                    }
                }
                .padding(.vertical)
                .background(Color(white: 0.13))
                .cornerRadius(12)

                // Alert type
                VStack {
                    Picker(selection: $paceAlertType, content: {
                        Text("Beep").tag(PaceAlertType.beep)
                        Text("Speech").tag(PaceAlertType.speech)
                        Text("Ding").tag(PaceAlertType.ding)
                    }, label: {
                        Text("Alert type")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    })
                    .pickerStyle(.navigationLink)
                    .onChange(of: paceAlertType) { _ in
                        UserDefaults.standard.set(paceAlertType.rawValue, forKey: AppStorageKey.paceAlertType)
                    }

                    if case .workoutNotActive = context {
                        HStack {
                            Button(action: { testAlertType(.tooSlowAlert) }) {
                                VStack {
                                    Image(systemName: "bell.fill")
                                    Text("Test")
                                    Text("too slow")
                                }
                            }
                            Button(action: { testAlertType(.tooFastAlert) }) {
                                VStack {
                                    Image(systemName: "bell.fill")
                                    Text("Test")
                                    Text("too fast")
                                }
                            }
                        }
                    }

                    Toggle(isOn: $duckOthersOnAlert) {
                        VStack {
                            if duckOthersOnAlert {
                                Image(systemName: "checkmark.rectangle.fill")
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "xmark.rectangle.fill")
                                    .foregroundColor(.red)
                            }

                            Text("Lower other audio on alert")
                        }
                    }
                    .toggleStyle(.button)
                }

                // Measurement system
                Picker(selection: $measurementSystem, content: {
                    Text("Metric").tag(MeasurementSystem.metric)
                    Text("Imperial").tag(MeasurementSystem.freedomUnits🇺🇸🔫)
                }, label: {
                    Text("Measurement system")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                })
                .pickerStyle(.navigationLink)
                .onChange(of: measurementSystem, perform: { _ in
                    UserDefaults.standard.set(measurementSystem.rawValue, forKey: AppStorageKey.measurementSystem)
                })

                if case .workoutNotActive = context {
                    Spacer(minLength: 16)

                    // About
                    Text("About")
                        .font(.title2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(aboutString)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(.horizontal)
    }

    private func testAlertType(_ alert: WorkoutViewModel.PaceAlert) {
        guard let rawValue = UserDefaults.standard.string(forKey: AppStorageKey.paceAlertType),
              let alertType = PaceAlertType(rawValue: rawValue) else {
            return
        }

        let player = alertType.makeAlertPlayer()
        player.playAlert(alert)
        demoAlertPlayer = player
    }
}

struct SettingsViewPreview: PreviewProvider {
    static var previews: some View {
        SettingsView(context: .workoutNotActive)
            .previewDisplayName("Workout not active")
        SettingsView(context: .workoutActive)
            .previewDisplayName("Workout active")
    }
}


fileprivate let aboutString =
"""
BlazePace was developed to help you go faster by going slower. It will however just as happily make you go faster by going faster.

BlazePace is open source, and contributions and feedback is welcome at github:
pimms/blazepace

🐦 @superpimms

🔥❤️
"""
