import Foundation

class PaceSmoother {
    private struct Entry {
        let date: Date
        let dt: TimeInterval
        let distance: Double
    }

    @Published var smoothedPace: Pace

    private let kalman = KalmanFilter(q: 0.01, r: 0.1)
    private var entries: [Entry] = []

    init() {
        smoothedPace = Pace(secondsPerKilometer: 0)
    }

    @MainActor
    func addEntry(date: Date, deltaTime dt: TimeInterval, distance: Double) {
        cleanEntries()
        entries.append(Entry(date: date, dt: dt, distance: distance))

        let absoluteDistance = entries.map({ $0.distance }).reduce(0, +)
        let absoluteTime = entries.map({ $0.dt }).reduce(0, +)

        let metersPerSecond = absoluteDistance / absoluteTime
        let pace = 1.0 / (metersPerSecond / 1000)

        // let smoothed = kalman.addMeasurement(pace, dt: dt)
        self.smoothedPace = Pace(secondsPerKilometer: Int(pace))
    }

    private func cleanEntries() {
        var index = 0
        let cutoff = Date() - 20
        while entries.count > index, entries[index].date < cutoff {
            index += 1
        }
        entries.removeFirst(index)
    }
}

private class KalmanFilter {
    private var x: Double = 0.0
    private var p: Double = 1.0
    private let q: Double
    private let r: Double

    init(q: Double, r: Double) {
        self.q = q
        self.r = r
    }

    func addMeasurement(_ z: Double, dt: TimeInterval) -> Double {
        // Predict
        let xp = x
        let pp = p + q

        // Update
        let k = pp / (pp + r)
        x = xp + k * (z - xp)
        p = (1 - k) * pp

        // Return smoothed value
        return x / dt
    }
}
