import Foundation
import SwiftUI

struct DigitalCrownTargetPaceModifier: ViewModifier {
    @ObservedObject var viewModel: WorkoutViewModel

    @State private var digitalCrown: Double = 0
    @State private var crownStartValue: Double = 0
    @State private var paceTicks = 0
    @State private var isRotating = false
    @State private var newPace: TargetPace

    init(_ viewModel: WorkoutViewModel) {
        _viewModel = .init(initialValue: viewModel)
        _newPace = .init(initialValue: viewModel.targetPace)
    }

    func body(content: Content) -> some View {
        content
            .focusable()
            .digitalCrownRotation($digitalCrown, onChange: { event in
                if !self.isRotating {
                    self.crownStartValue = digitalCrown
                    self.paceTicks = 0
                    self.isRotating = true
                }

                let relative = digitalCrown - crownStartValue
                self.paceTicks = Int(relative / 100) * -1
                self.newPace = TargetPace(
                    secondsPerKilometer: viewModel.targetPace.secondsPerKilometer + (TargetPace.paceIncrement * paceTicks),
                    range: viewModel.targetPace.range)
            }, onIdle: {
                self.isRotating = false
                if self.paceTicks != 0 {
                    viewModel.targetPace = newPace
                }
            })
            .digitalCrownAccessory(.hidden)
            .overlay {
                ChangePaceView(newPace: newPace)
                    .opacity(isRotating ? 1 : 0)
                    .animation(.linear, value: isRotating)
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
            let lowBound = PaceFormatter.paceString(fromSecondsPerKilometer: newPace.lowerBound)
            let highBound = PaceFormatter.paceString(fromSecondsPerKilometer: newPace.upperBound)
            VStack {
                Spacer()
                Text("New target:")
                Text("\(lowBound)-\(highBound)")
                    .font(compact ? .title2 : .title)
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
