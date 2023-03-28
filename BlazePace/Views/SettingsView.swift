import Foundation
import SwiftUI

struct SettingsView: View {
    @AppStorage(AppStorageKey.paceNotificationInterval)
    private var paceNotificationInterval: TimeInterval = 1

    static let aboutString =
"""
BlazePace was developed to help you go faster by going slower. It will however just as happily make you go faster by going faster.

BlazePace is open source, and contributions and feedback is welcome at github:
pimms/blazepace

🐦 @superpimms

🔥❤️
"""

    var body: some View {
        ScrollView {
            VStack {
                Text("Pace notification interval")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Stepper(value: $paceNotificationInterval, in: 2...10, step: 0.25) {
                    Text(String(format: "%.2f s", paceNotificationInterval))
                        .font(.body)
                }

                Spacer(minLength: 16)

                Text("About")
                    .font(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(Self.aboutString)
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
