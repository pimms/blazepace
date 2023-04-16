import Foundation
import CoreLocation

protocol DiagBuilderProtocol {
    func addLocation(_ loc: CLLocation)
    func finalize(with workoutSummary: WorkoutSummary)
}

typealias DiagBuilder = NoopDiagBuilder

class NoopDiagBuilder: DiagBuilderProtocol {
    func addLocation(_ loc: CLLocation) {}
    func finalize(with workoutSummary: WorkoutSummary) {}
}

#if DEBUG
class RealDiagBuilder: DiagBuilderProtocol {
    private let log = Log(name: "DiagBuilder")
    private let repository = DiagRepository()
    private var summary = DiagSummary()

    func addLocation(_ loc: CLLocation) {
        log.debug("Adding location")
        let entry = DiagSummary.Entry(
            lat: loc.coordinate.latitude,
            lon: loc.coordinate.longitude,
            t: loc.timestamp.timeIntervalSince(summary.startTime))
        summary.entries.append(entry)
    }

    func finalize(with workoutSummary: WorkoutSummary) {
        log.debug("Finalizing")
        let title = workoutSummary.workoutType.rawValue
        summary.title = title
        summary.endTime = Date()

        let kms = workoutSummary.distance.converted(to: .kilometers).value
        let dur = PaceFormatter.durationString(from: Int(workoutSummary.elapsedTime))
        let pace = PaceFormatter.minuteString(fromSeconds: workoutSummary.averagePace.secondsPerKilometer)
        let description = "\(kms)km, \(dur)\np\(pace)"

        Task {
            await repository.addSummary(
                summary,
                title: title,
                description: description)
        }
    }
}
#endif
