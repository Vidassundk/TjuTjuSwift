//
//  WorkoutExercise.swift
//  TjuTju
//
//  Created by Vidas Sun on 28/05/2025.
//

import Foundation
import SwiftData

@Model
class WorkoutExercise {
    var exercise: Exercise
    var sets: [ExerciseSet]

    init(exercise: Exercise, sets: [ExerciseSet]) {
        self.exercise = exercise
        self.sets = sets
    }
}
