//
//  Measurement.swift
//  TjuTju
//
//  Created by Vidas Sun on 28/05/2025.
//

import Foundation

enum Measurement: String, Codable, CaseIterable {
    case weight = "Weight"
    case time = "Time"
    case distance = "Distance"
    case bodyWeight = "Bodyweight"  // 🆗 camelCase for code, title case for UI
}
