import Foundation
import SwiftData

enum UnitSystem: String, Codable, CaseIterable {
    case metric = "metric"
    case imperial = "imperial"

    var label: String {
        switch self {
        case .metric: return "Metric (kg)"
        case .imperial: return "Imperial (lbs)"
        }
    }
}

@Model
class UserPreferences {
    var bodyWeight: Double?
    var preferredUnitSystem: UnitSystem?

    init(bodyWeight: Double? = nil, preferredUnitSystem: UnitSystem = .metric) {
        self.bodyWeight = bodyWeight
        self.preferredUnitSystem = preferredUnitSystem
    }
}
