import Foundation

struct WorkoutSummary: Hashable {
    let workoutType: WorkoutType
    let distance: Measurement<UnitLength>
    let elapsedTime: TimeInterval
    let averagePace: Pace
    let targetPace: TargetPace
}
