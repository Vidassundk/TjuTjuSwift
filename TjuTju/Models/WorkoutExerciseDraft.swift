//
//  WorkoutExerciseDraft.swift
//  TjuTju
//
//  Created by Vidas Sun on 02/06/2025.
//

import Foundation

struct WorkoutExerciseDraft: Identifiable {
    let id = UUID()
    let exercise: Exercise
    var sets: [ExerciseSetDraft]
}

struct ExerciseSetDraft: Identifiable {
    let id = UUID()
    var reps: Int
    var values: [Double]  // one per measurement
}
