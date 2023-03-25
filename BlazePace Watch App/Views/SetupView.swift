import Foundation
import SwiftUI

struct SetupView: View {
    var onStart: (TargetPace) -> Void

    @AppStorage(AppStorageKey.defaultPace)
    private var pace: Int = 300
    @AppStorage(AppStorageKey.defaultPaceRange)
    private var delta: Int = 10

    var body: some View {
        ScrollView {
            VStack {
                Text("Pace").frame(maxWidth: .infinity, alignment: .leading)
                Stepper(value: $pace, in: 120...600, step: 5) {
                    Text(PaceFormatter.minuteString(fromSeconds: pace))
                        .font(.title3)
                }
                
                Text("Delta").frame(maxWidth: .infinity, alignment: .leading)
                Stepper(value: $delta, in: 1...30) {
                    Text("± \(delta)s").font(.title3)
                }
                
                Text("\(PaceFormatter.minuteString(fromSeconds: pace - delta)) - \(PaceFormatter.minuteString(fromSeconds: pace + delta))")
                
                Button(action: { startButtonClicked() }) {
                    Text("Start")
                }
            }
        }
        .navigationTitle("Setup")
    }

    private func startButtonClicked() {
        let targetPace = TargetPace(secondsPerKilometer: pace, range: delta)
        onStart(targetPace)
    }
}

struct ConfigViewPreviews: PreviewProvider {
    static var previews: some View {
        SetupView(onStart: { _ in })
    }
}