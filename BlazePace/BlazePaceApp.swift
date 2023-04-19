import SwiftUI
import AVFoundation

@main
struct BlazePace_Watch_AppApp: App {
    @ObservedObject private var workoutController = WorkoutController.shared
    @State private var healthKitError = false
    @State private var coreLocationError = false
    @State private var hasInitialized = false

    var body: some Scene {
        WindowGroup {
            Group {
                if !hasInitialized {
                    SpinnerView(text: nil)
                } else {
                    RootView()
                }
            }
            .alert("Failed to acquire HealthKit permissions", isPresented: $healthKitError) {
                Button("OK", role: .cancel) {
                    healthKitError = false
                }
            }
            .alert("Failed to acquire location permissions. Workout data will be imprecise.", isPresented: $coreLocationError) {
                Button("OK", role: .cancel) {
                    coreLocationError = false
                }
            }
            .onAppear(perform: {
                guard !hasInitialized else { return }
                AVHelper.updateAudioCategory()

                Task {
                    let permissionHelper = PermissionHelper()
                    if await !permissionHelper.requestHealthKitPermissions() {
                        healthKitError = true
                    }

                    if await !permissionHelper.requestLocationPermission() {
                        coreLocationError = true
                    }

                    await workoutController.restoreWorkoutSession()
                    hasInitialized = true
                }
            })
        }
    }
}
