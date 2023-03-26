import Foundation
import SwiftUI

struct WorkoutManagementView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @Binding var navigationStack: [Navigation]

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    WorkoutButton(
                        sfSymbol: "xmark",
                        color: .red,
                        onClick: { endWorkout() })

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

                HStack {
                    WorkoutButton(
                        sfSymbol: viewModel.playNotifications ? "bell.fill" : "bell.slash",
                        color: .blue,
                        onClick: muteButtonClicked)

                }

                NavigationLink(value: Navigation.editTargetPace) {
                    VStack {
                        Text("Edit target")
                            .bold()
                        Text("\(PaceFormatter.minuteString(fromSeconds: viewModel.targetPace.lowerBound)) - \(PaceFormatter.minuteString(fromSeconds: viewModel.targetPace.upperBound))")
                            .fontWeight(.light)
                    }
                }
                .frame(height: 64)
                .foregroundColor(.black)
                .background(Color.green.cornerRadius(8))
            }
            .padding(.horizontal, 20)
        }
    }

    private func endWorkout() {
        Task {
            if let summary = await viewModel.endWorkout() {
                navigationStack.append(.summary(summary))
            }
        }
    }

    private func muteButtonClicked() {
        viewModel.playNotifications.toggle()
    }
}

struct EditTargetPaceMidWorkoutView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @State private var pace: Int
    @State private var delta: Int

    init(viewModel: WorkoutViewModel) {
        self.viewModel = viewModel
        _pace = .init(initialValue: viewModel.targetPace.secondsPerKilometer)
        _delta = .init(initialValue: viewModel.targetPace.range)
    }

    var body: some View {
        ScrollView {
            Spacer()
            EditTargetPaceView(pace: $pace, delta: $delta)
                .onChange(of: pace, perform: { _ in valueChanged() })
                .onChange(of: delta, perform: { _ in valueChanged() })
        }
        .navigationTitle("Edit pace")
    }

    private func valueChanged() {
        let targetPace = TargetPace(secondsPerKilometer: pace, range: delta)
        viewModel.targetPace = targetPace
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
                .frame(maxWidth: 24, maxHeight: 24)
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
            .frame(maxWidth: .infinity)
            .background(background.cornerRadius(8))
            .foregroundColor(foreground)
    }
}

struct WorkoutManagementViewPreview: PreviewProvider {
    static func viewModel(active: Bool) -> WorkoutViewModel {
        let vm = WorkoutViewModel(workoutType: .running, targetPace: TargetPace(secondsPerKilometer: 300, range: 10))
        vm.isActive = active
        return vm
    }

    static var previews: some View {
        Group {
            WorkoutManagementView(viewModel: viewModel(active: false), navigationStack: .constant([]))
            WorkoutManagementView(viewModel: viewModel(active: true), navigationStack: .constant([]))

            EditTargetPaceMidWorkoutView(viewModel: viewModel(active: true))
        }
    }
}
