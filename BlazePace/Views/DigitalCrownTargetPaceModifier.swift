import Foundation
import SwiftUI

struct DigitalCrownTargetPaceModifier: ViewModifier {
    private enum CrownState: Equatable {
        case idle
        case active
        case idling
    }

    @ObservedObject var viewModel: WorkoutViewModel

    @State private var digitalCrown: Double = 0
    @State private var crownStartValue: Double = 0
    @State private var paceTicks = 0
    @State private var crownState = CrownState.idle
    @State private var newPace: TargetPace

    init(_ viewModel: WorkoutViewModel) {
        _viewModel = .init(initialValue: viewModel)
        _newPace = .init(initialValue: viewModel.targetPace)
    }

    func body(content: Content) -> some View {
        content
            .focusable()
            .digitalCrownRotation($digitalCrown, onChange: { event in
                if self.crownState == .idle {
                    self.crownStartValue = digitalCrown
                    self.paceTicks = 0
                    self.crownState = .active
                }

                let relative = digitalCrown - crownStartValue
                self.paceTicks = Int(relative / 100) * -1
                self.newPace = TargetPace(
                    secondsPerKilometer: viewModel.targetPace.secondsPerKilometer + (TargetPace.paceIncrement * paceTicks),
                    range: viewModel.targetPace.range)
            }, onIdle: {
                self.crownState = .idling
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    guard self.crownState == .idling else { return }
                    self.crownState = .idle
                    if self.paceTicks != 0 {
                        viewModel.targetPace = newPace
                    }
                }
            })
            .digitalCrownAccessory(.hidden)
            .overlay {
                ChangePaceView(newPace: newPace)
                    .opacity(crownState == .idle ? 0 : 1)
                    .animation(.linear, value: crownState)
            }
    }
}

private struct ChangePaceView: View {
    let newPace: TargetPace
    @Environment(\.compact) private var compact

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.blue)
                .frame(width: 100, height: 60)
            let target = PaceFormatter.paceString(fromSecondsPerKilometer: newPace.secondsPerKilometer)
            let lowBound = PaceFormatter.paceString(fromSecondsPerKilometer: newPace.lowerBound)
            let highBound = PaceFormatter.paceString(fromSecondsPerKilometer: newPace.upperBound)
            VStack {
                Spacer()
                Text("New target:")
                Text(target)
                    .font(.title)
                Spacer()
                Text("\(lowBound)-\(highBound)")
                    .font(.title3)
                Spacer()
            }
            .foregroundColor(.black)
            .bold()
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color.yellow
                    .cornerRadius(8, corners: .allCorners)
            }
            .padding()
        }
    }
}

extension View {
    func digitalCrownTargetPaceAdjuster(_ viewModel: WorkoutViewModel) -> some View {
        return self.modifier(DigitalCrownTargetPaceModifier(viewModel))
    }
}

struct ChangePaceViewPreview: PreviewProvider {
    static var previews: some View {
        ChangePaceView(newPace: TargetPace(secondsPerKilometer: 300, range: 15))
    }
}
