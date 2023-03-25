import Foundation
import SwiftUI

struct RootView: View {
    @ObservedObject var workoutController = WorkoutController.shared
    @State var navigation: [Navigation] = []
    @State var healthKitError: Bool = false

    var body: some View {
        NavigationStack(path: $navigation) {
            contentView
                .navigationDestination(for: Navigation.self) { navigation in
                    switch navigation {
                    case .setup:
                        SetupView()
                    }
                }
                .alert("Failed to acquire HealthKit permissions", isPresented: $healthKitError) {
                    Button("OK", role: .cancel) {
                        healthKitError = false
                    }
                }
        }
        .onAppear(perform: {
            PermissionHelper.shared.requestHealthKitPermissions(onError: { error in
                healthKitError = true
            })
        })
    }

    var contentView: some View {
        MainView()
    }
}

struct RootViewPreview: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
