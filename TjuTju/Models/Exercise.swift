//
//  Exercise.swift
//  TjuTju
//
//  Created by Vidas Sun on 28/05/2025.
//

import Foundation
import SwiftData

@Model
class Exercise: Hashable {
    var name: String
    var exerciseCategories: [ExerciseCategory]
    var measurements: [Measurement]

    init(
        name: String,
        exerciseCategories: [ExerciseCategory],  // ✅ match the property name
        measurements: [Measurement]
    ) {
        self.name = name
        self.exerciseCategories = exerciseCategories
        self.measurements = measurements
    }

    // Required for Set<Exercise> selection logic
    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
