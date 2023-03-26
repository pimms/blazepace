import Foundation
import SwiftUI

struct WorkoutManagementView: View {
    @ObservedObject var viewModel: WorkoutViewModel

    var body: some View {
        VStack {
            HStack {
                WorkoutButton(
                    sfSymbol: "xmark",
                    color: .red,
                    onClick: { viewModel.endWorkout() })

                if viewModel.isActive {
                    WorkoutButton(
                        sfSymbol: "pause",
                        color: .yellow,
                        onClick: { viewModel.pauseWorkout() })
                } else {
                    WorkoutButton(
                        sfSymbol: "play.fill",
                        color: .green,
                        onClick: { viewModel.resumeWorkout() })
                }
            }
        }
    }
}

private struct WorkoutButton: View {
    let sfSymbol: String
    let color: Color
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            Image(systemName: sfSymbol)
                .resizable()
                .bold()
                .frame(maxWidth: 32, maxHeight: 32)
                .aspectRatio(contentMode: .fit)
        }
        .buttonStyle(WorkoutButtonStyle(background: color.opacity(0.4), foreground: color))
    }
}

private struct WorkoutButtonStyle: ButtonStyle {
    let background: Color
    let foreground: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .padding(20)
            .background(background.cornerRadius(8))
            .foregroundColor(foreground)
    }
}

struct WorkoutManagementViewPreview: PreviewProvider {
    static func viewModel(active: Bool) -> WorkoutViewModel {
        let vm = WorkoutViewModel()
        vm.isActive = active
        return vm
    }

    static var previews: some View {
        Group {
            WorkoutManagementView(viewModel: viewModel(active: false))
            WorkoutManagementView(viewModel: viewModel(active: true))
        }
    }
}
