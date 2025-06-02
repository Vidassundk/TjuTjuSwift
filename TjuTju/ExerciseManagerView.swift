//
//  ExerciseManagerView.swift
//  TjuTju
//
//  Created by Vidas Sun on 02/06/2025.
//

import SwiftData
import SwiftUI

struct ExerciseManagerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var exercises: [Exercise]

    @State private var editingExercise: Exercise? = nil

    var body: some View {
        List {
            ForEach(exercises) { exercise in
                Button {
                    editingExercise = exercise
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.name)
                            .font(.headline)
                        Text(
                            "\(exercise.exerciseCategories.map { $0.name }.joined(separator: ", "))"
                        )
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        Text(
                            "Measurements: \(exercise.measurements.map(\.rawValue).joined(separator: ", "))"
                        )
                        .font(.caption)
                    }
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    modelContext.delete(exercises[index])
                }
            }
        }
        .navigationTitle("Exercise Manager")
        .sheet(item: $editingExercise) { exercise in
            EditExerciseView(exercise: exercise)
        }
    }
}

#Preview {
    ExerciseManagerView()
}
