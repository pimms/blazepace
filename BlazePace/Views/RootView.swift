import Foundation
import SwiftUI

struct RootView: View {
    @ObservedObject var workoutController = WorkoutController.shared
    @State var navigation: [Navigation] = []
    @State var healthKitError: Bool = false

    var body: some View {
        NavigationStack(path: $navigation) {
            contentView()
                .navigationDestination(for: Navigation.self) { navigation in
                    switch navigation {
                    case .setup:
                        SetupView(onStart: startWorkout(with:))
                    case .settings:
                        SettingsView()
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
        }
        .onAppear(perform: {
            PermissionHelper.shared.requestHealthKitPermissions(onError: { error in
                healthKitError = true
            })
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
        if let viewModel = workoutController.viewModel {
            WorkoutTabView(viewModel: viewModel, navigationStack: $navigation)
        } else {
            MainView()
        }
    }
}

struct RootViewPreview: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
