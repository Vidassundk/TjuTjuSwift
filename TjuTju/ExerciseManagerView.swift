//
//  ExerciseManagerView.swift
//  TjuTju
//
//  Created by Vidas Sun on 02/06/2025.
//
//  This view displays a list of all available exercises, allowing users
//  to edit existing ones, delete them, or create new ones.
//

import SwiftData
import SwiftUI

struct ExerciseManagerView: View {
    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext

    // MARK: - Data Queries

    /// Fetches all exercises, sorted alphabetically by name for a consistent UI.
    @Query(sort: \Exercise.name) private var exercises: [Exercise]

    // MARK: - State

    /// The exercise currently being edited. When this is non-nil, the edit sheet is presented.
    @State private var editingExercise: Exercise?

    /// Controls the presentation of the sheet for creating a new exercise.
    @State private var isPresentingCreateSheet = false

    // MARK: - Body

    var body: some View {
        List {
            ForEach(exercises) { exercise in
                exerciseRow(for: exercise)
            }
            .onDelete(perform: deleteExercises)
        }
        .navigationTitle("Exercise Manager")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isPresentingCreateSheet = true
                } label: {
                    Label("Create New Exercise", systemImage: "plus")
                }
            }
        }
        // A sheet for editing an existing exercise, triggered by tapping a row.
        .sheet(item: $editingExercise) { exercise in
            EditExerciseView(exercise: exercise)
        }
        // A sheet for creating a new exercise, triggered by the toolbar button.
        .sheet(isPresented: $isPresentingCreateSheet) {
            CreateExerciseView()
        }
        // An overlay that provides a helpful message when the list is empty.
        .overlay {
            if exercises.isEmpty {
                ContentUnavailableView(
                    "No Exercises Found",
                    systemImage: "figure.strengthtraining.traditional",
                    description: Text(
                        "Create your first exercise to get started.")
                )
            }
        }
    }

    // MARK: - View Components

    /// Builds the view for a single row in the exercise list.
    private func exerciseRow(for exercise: Exercise) -> some View {
        Button {
            editingExercise = exercise
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.headline)

                // Display categories if they exist.
                if !exercise.exerciseCategories.isEmpty {
                    Text(
                        exercise.exerciseCategories.map(\.name).joined(
                            separator: ", ")
                    )
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }

                // Display measurements.
                Text(
                    "Tracking: \(exercise.measurements.map(\.rawValue).joined(separator: ", "))"
                )
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())  // Ensures the text color is standard.
    }

    // MARK: - Private Methods

    /// Deletes exercises from the model context at the specified offsets.
    private func deleteExercises(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(exercises[index])
        }
    }
}

#Preview {
    NavigationStack {
        ExerciseManagerView()
            .modelContainer(for: [Exercise.self], inMemory: true)
    }
}
