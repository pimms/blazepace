import Foundation
import SwiftUI

struct SettingsView: View {
    @AppStorage(AppStorageKey.paceNotifications)
    private var paceNotifications: Bool = true

    @AppStorage(AppStorageKey.paceNotificationInterval)
    private var paceNotificationInterval: TimeInterval = 1

    var body: some View {
        ScrollView {
            VStack {
                Toggle(isOn: $paceNotifications) {
                    Text("Pace notifications")
                }

                Spacer(minLength: 8)

                Text("Pace notification interval")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Stepper(value: $paceNotificationInterval, in: 0.5...10, step: 0.25) {
                    Text(String(format: "%.2f s", paceNotificationInterval))
                        .font(.body)
                }

                Spacer(minLength: 16)

                Text("About")
                    .font(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("ⓒ Joakim Stien\n\n" +
                     "BlazePace is open source, and contributions and feedback is welcome at github:\npimms/blazepace\n\n" +
                     "🐦 @pimms\n" +
                     "🔥❤️"
                )
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
