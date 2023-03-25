import Foundation
import Combine

class RunViewModel: ObservableObject {
    @Published var targetPace: TargetPace?
    @Published var currentPace: Pace?
    @Published var averagePace: Pace?
    @Published var heartRate: Int?
    @Published var distanceInMeters: Int?

    init() {

    }
}
