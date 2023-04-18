import Foundation
import SwiftUI

struct IsCompactEnvVal: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var compact: Bool {
        get { self[IsCompactEnvVal.self] }
        set { self[IsCompactEnvVal.self] = newValue }
    }
}
