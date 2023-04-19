import Foundation
import SwiftUI
import AVFoundation

struct RootView: View {
    @ObservedObject private var workoutController = WorkoutController.shared
    @State private var navigation: [Navigation] = []

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
        }
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
            .environment(\.compact, WKInterfaceDevice.current().screenBounds.width < 160)
    }
}
