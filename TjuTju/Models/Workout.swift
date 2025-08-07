//
//  Workout.swift
//  TjuTju
//
//  Created by Vidas Sun on 28/05/2025.
//

import Foundation
import SwiftData

@Model
class Workout {
    var name: String
    var exercises: [WorkoutExercise]
    var duration: TimeInterval?
    var progressiveOverload: Bool

    init(
        name: String,
        exercises: [WorkoutExercise],
        duration: TimeInterval? = nil,
        progressiveOverload: Bool
    ) {
        self.name = name
        self.exercises = exercises
        self.duration = duration
        self.progressiveOverload = progressiveOverload
    }
}
