import Foundation
import SwiftUI

struct SetupView: View {
    @State private var pace: Int = 300
    @State private var delta: Int = 10

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
                
                Button(action: {}) {
                    Text("Start")
                }
            }
        }
        .navigationTitle("Setup")

    }
}

struct ConfigViewPreviews: PreviewProvider {
    static var previews: some View {
        SetupView()
    }
}
