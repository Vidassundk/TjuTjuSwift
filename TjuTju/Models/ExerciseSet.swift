//
//  ExerciseSet.swift
//  TjuTju
//
//  Created by Vidas Sun on 28/05/2025.
//

import Foundation
import SwiftData

@Model
class ExerciseSet {
    var reps: Int?
    var values: [Double]

    init(reps: Int? = nil, values: [Double]) {
        self.reps = reps
        self.values = values
    }
}
