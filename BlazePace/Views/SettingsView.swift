import Foundation
import SwiftUI

struct SettingsView: View {
    @AppStorage(AppStorageKey.paceAlertInterval)
    private var paceNotificationInterval: TimeInterval = 5

    @State private var paceAlertType: PaceAlertType
    @State private var measurementSystem: MeasurementSystem

    init() {
        let alertString = UserDefaults.standard.string(forKey: AppStorageKey.paceAlertType) ?? ""
        _paceAlertType = .init(initialValue: PaceAlertType(rawValue: alertString) ?? .ding)
        _measurementSystem = .init(initialValue: MeasurementSystem.current)
    }

    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    Text("Alert interval")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    Stepper(value: $paceNotificationInterval, in: 2...10, step: 0.25) {
                        Text(String(format: "%.2f s", paceNotificationInterval))
                            .font(.body)
                    }
                }
                .padding()
                .background(Color(white: 0.13))
                .cornerRadius(12)

                Picker(selection: $paceAlertType, content: {
                    Text("Ding").tag(PaceAlertType.ding)
                    Text("Speech").tag(PaceAlertType.speech)
                }, label: {
                    Text("Alert type")
                        .frame(maxWidth: .infinity, alignment: .leading)
                })
                .pickerStyle(.navigationLink)
                .padding(.vertical)
                .onChange(of: paceAlertType) { _ in
                    UserDefaults.standard.set(paceAlertType.rawValue, forKey: AppStorageKey.paceAlertType)
                }

                Picker(selection: $measurementSystem, content: {
                    Text("Metric").tag(MeasurementSystem.metric)
                    Text("Imperial").tag(MeasurementSystem.freedomUnits🇺🇸🔫)
                }, label: {
                    Text("Measurement system")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                })
                .pickerStyle(.navigationLink)
                .padding(.vertical)
                .onChange(of: measurementSystem, perform: { _ in
                    UserDefaults.standard.set(measurementSystem.rawValue, forKey: AppStorageKey.measurementSystem)
                })

                Spacer(minLength: 16)

                Text("About")
                    .font(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(aboutString)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal)
    }
}

struct SettingsViewPreview: PreviewProvider {
    static var previews: some View {
        SettingsView()
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
