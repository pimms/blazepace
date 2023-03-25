import Foundation
import SwiftUI

struct WorkoutManagementView: View {
    let viewModel: any WorkoutManaging

    var body: some View {
        VStack {
            HStack {
                WorkoutButton(
                    sfSymbol: "xmark",
                    color: .red,
                    onClick: { viewModel.endWorkout() })
                WorkoutButton(
                    sfSymbol: "pause",
                    color: .yellow,
                    onClick: { viewModel.pauseWorkout() })
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
    private struct MockWorkoutManaging: WorkoutManaging {
        func pauseWorkout() {}
        func endWorkout() {}
    }

    static var previews: some View {
        WorkoutManagementView(viewModel: MockWorkoutManaging())
    }
}
