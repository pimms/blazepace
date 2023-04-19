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
        #if DEBUG
        guard Self.threshold.rawValue >= Level.debug.rawValue else { return }
        print("[BP][🐛][\(name)] \(text())")
        #endif
    }

    func info(_ text: @autoclosure () -> String) {
        #if DEBUG
        guard Self.threshold.rawValue >= Level.info.rawValue else { return }
        print("[BP][ℹ️][\(name)] \(text())")
        #endif
    }

    func error(_ text: @autoclosure () -> String) {
        #if DEBUG
        guard Self.threshold.rawValue >= Level.error.rawValue else { return }
        print("[BP][🚨][\(name)] \(text())")
        #endif
    }
}
