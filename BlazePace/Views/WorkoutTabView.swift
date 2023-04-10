import Foundation
import SwiftUI
import WatchKit

struct WorkoutTabView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @Binding var navigationStack: [Navigation]

    @State private var selection = 1

    var body: some View {
        TabView(selection: $selection) {
            WorkoutManagementView(viewModel: viewModel, navigationStack: $navigationStack)
                .tag(0)
            MetricOverview(viewModel: viewModel)
                .tag(1)
            NowPlayingView()
                .tag(2)
        }
    }
}

struct WorkoutTabViewPreview: PreviewProvider {
    static let viewModel = WorkoutViewModel(
        workoutType: .running,
        startDate: Date(),
        targetPace: TargetPace(secondsPerKilometer: 300, range: 10))

    static var previews: some View {
        WorkoutTabView(viewModel: viewModel, navigationStack: .constant([]))
    }
}
