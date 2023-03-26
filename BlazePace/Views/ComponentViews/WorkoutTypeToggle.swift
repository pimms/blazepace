import Foundation
import SwiftUI

struct WorkoutTypeToggle: View {
    @Binding var workoutType: WorkoutType

    var body: some View {
        HStack(spacing: 0) {
            Button(action: { workoutType = .running }, label: {
                VStack {
                    Image(systemName: "figure.run")
                    Text("run")
                }
            }).buttonStyle(ToggleButtonStyle(roundCorners: .left, isSelected: workoutType == .running))
            Button(action: { workoutType = .walking }, label: {
                VStack {
                    Image(systemName: "figure.walk")
                    Text("walk")
                }
            }).buttonStyle(ToggleButtonStyle(roundCorners: .right, isSelected: workoutType == .walking))
        }
    }
}

private struct ToggleButtonStyle: ButtonStyle {
    enum RoundedCorners: Hashable {
        case left
        case right

        var corners: UIRectCorner {
            switch self {
            case .left:
                return [.topLeft, .bottomLeft]
            case .right:
                return [.topRight, .bottomRight]
            }
        }
    }

    let roundCorners: RoundedCorners
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        // Only round either the left or right corners based on 'roundCorners'.
        // Make the button stand out if selected, and dim it a little bit if it's not.
        configuration.label
            .font(isSelected ? .caption.bold() : .caption.weight(.light))
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .foregroundColor(
                Color.black
                    .opacity(isSelected ? 1 : 0.5)
            )
            .background(content: {
                Color.green
                    .opacity(isSelected ? 1 : 0.5)
                    .cornerRadius(8, corners: roundCorners.corners)
            })

    }
}

struct WorkoutTypeTogglePreviews: PreviewProvider {
    @State static var workoutType: WorkoutType = .running
    static var previews: some View {
        WorkoutTypeToggle(workoutType: $workoutType)
    }
}
