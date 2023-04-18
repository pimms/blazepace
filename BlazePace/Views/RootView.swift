import Foundation
import SwiftUI
import AVFoundation

struct RootView: View {
    @ObservedObject var workoutController = WorkoutController.shared
    @State var navigation: [Navigation] = []
    @State var healthKitError = false
    @State var coreLocationError = false
    @State var hasInitialized = false

    var body: some View {
        NavigationStack(path: $navigation) {
            contentView()
                .navigationDestination(for: Navigation.self) { navigation in
                    switch navigation {
                    case .setup:
                        SetupView(onStart: startWorkout(with:))
                    case .settings(let context):
                        SettingsView(context: context)
                    case .editTargetPace:
                        if let viewModel = workoutController.viewModel {
                            EditTargetPaceMidWorkoutView(viewModel: viewModel)
                        } else {
                            Text("Internal error 😭")
                        }
                    case .summary(let summary):
                        SummaryView(summary: summary, navigationStack: $navigation)
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
        }
        .onAppear(perform: {
            try? AVAudioSession.sharedInstance().setCategory(.playback, options: .duckOthers)

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

    private func startWorkout(with startData: WorkoutStartData) {
        Task {
            let didStart = await workoutController.startWorkout(startData)
            guard didStart else { return }
            guard let viewModel = workoutController.viewModel else {
                fatalError("Inconsistency: no view model on WorkoutController")
            }
            viewModel.targetPace = startData.targetPace
            navigation = []
        }
    }

    @ViewBuilder
    func contentView() -> some View {
        if !hasInitialized {
            SpinnerView(text: "hi mom")
        } else if let viewModel = workoutController.viewModel {
            WorkoutTabView(viewModel: viewModel, navigationStack: $navigation)
        } else {
            MainView()
        }
    }
}

struct RootViewPreview: PreviewProvider {
    static var previews: some View {
        RootView()
            .environment(\.compact, WKInterfaceDevice.current().screenBounds.width < 160)
    }
}
