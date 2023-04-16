import Foundation
import HealthKit

extension HKWorkoutBuilder {
    private var workoutTypeKey: String { "bpWorkoutType" }
    private var targetPaceBase: String { "bpTargetPaceBase" }
    private var targetPaceDelta: String { "bpTargetPaceDelta" }

    var startData: WorkoutStartData {
        get {
            let workoutType: WorkoutType
            if let workoutTypeRawValue = metadata[workoutTypeKey] as? String,
               let type = WorkoutType(rawValue: workoutTypeRawValue) {
                workoutType = type
            } else {
                workoutType = .default
            }

            let targetPace: TargetPace
            if let pace = metadata[targetPaceBase] as? Int,
               let delta = metadata[targetPaceDelta] as? Int {
                targetPace = TargetPace(secondsPerKilometer: pace, range: delta)
            } else {
                targetPace = .default
            }

            return WorkoutStartData(workoutType: workoutType, targetPace: targetPace)
        }
        set {
            addMetadata([
                workoutTypeKey: newValue.workoutType.rawValue,
                targetPaceBase: newValue.targetPace.secondsPerKilometer,
                targetPaceDelta: newValue.targetPace.range
            ], completion: { (success, error) in
                guard success else {
                    fatalError("Failed to set WorkoutStartData on HKWorkoutBuilder: \(String(describing: error))")
                }
            })
        }
    }
}
