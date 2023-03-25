import Foundation

struct Log {
    enum Level: Int {
        case error = 0
        case info = 5
        case debug = 10
    }

    static let threshold: Level = .debug

    let name: String

    func debug(_ text: @autoclosure () -> String) {
        guard Self.threshold.rawValue >= Level.debug.rawValue else { return }
        print("[🐛][\(name)] \(text())")
    }

    func info(_ text: @autoclosure () -> String) {
        guard Self.threshold.rawValue >= Level.info.rawValue else { return }
        print("[ℹ️][\(name)] \(text())")
    }

    func error(_ text: @autoclosure () -> String) {
        guard Self.threshold.rawValue >= Level.error.rawValue else { return }
        print("[🚨][\(name)] \(text())")
    }
}
