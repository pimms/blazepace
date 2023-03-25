import Foundation
import SwiftUI

struct WorkoutTabView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @State private var selection = 1

    var body: some View {
        TabView(selection: $selection) {
            WorkoutManagementView(viewModel: viewModel)
                .tag(0)

            MetricOverview(viewModel: viewModel)
                .tag(1)
        }
    }
}

struct WorkoutTabViewPreview: PreviewProvider {
    static let viewModel = WorkoutViewModel()

    static var previews: some View {
        WorkoutTabView(viewModel: viewModel)
    }
}
