import Foundation
import SwiftUI

struct SettingsView: View {
    @AppStorage(AppStorageKey.paceNotifications)
    private var paceNotifications: Bool = true

    @AppStorage(AppStorageKey.paceNotificationInterval)
    private var paceNotificationInterval: Int = 2

    var body: some View {
        ScrollView {
            Toggle(isOn: $paceNotifications) {
                Text("Pace notifications")
            }

            Spacer()

            Text("Pace notification interval")
                .frame(maxWidth: .infinity, alignment: .leading)
            Stepper(value: $paceNotificationInterval) {
                Text("\(paceNotificationInterval) s")
                    .font(.body)
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
