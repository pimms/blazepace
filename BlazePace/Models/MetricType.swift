import Foundation

enum MeasurementSystem: String {
    static var current: MeasurementSystem {
        if let rawValue = UserDefaults.standard.string(forKey: AppStorageKey.measurementSystem),
           let type = MeasurementSystem(rawValue: rawValue) {
            return type
        }

        switch NSLocale.current.measurementSystem {
        case .metric, .uk:
            return .metric
        case .us:
            return .freedomUnits🇺🇸🔫
        default:
            return .metric
        }
    }

    case freedomUnits🇺🇸🔫 = "freedomUnits"
    case metric
}
