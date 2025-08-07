//
//  ExerciseSelectionView.swift
//  TjuTju
//
//  Created by Vidas Sun on 05/08/2025.
//
//  A view that allows users to select one or more exercises from a list.
//  It's typically presented as a sheet.
//

import SwiftUI

struct ExerciseSelectionView: View {
    // MARK: - Properties

    let allExercises: [Exercise]

    /// A binding to a Set that will store the user's selections.
    @Binding var selectedExercises: Set<Exercise>

    /// A closure that is called to dismiss the view.
    let onDismiss: () -> Void

    // MARK: - State

    @State private var isPresentingNewExercise = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List {
                ForEach(allExercises) { exercise in
                    exerciseRow(for: exercise)
                }
            }
            .navigationTitle("Select Exercises")
            .toolbar {
                // Toolbar button to create a new exercise.
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isPresentingNewExercise = true
                    } label: {
                        Label("New Exercise", systemImage: "plus")
                    }
                }

                // Toolbar button to confirm selection and dismiss the sheet.
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: onDismiss)
                }
            }
            .sheet(isPresented: $isPresentingNewExercise) {
                CreateExerciseView()
            }
            .overlay {
                if allExercises.isEmpty {
                    ContentUnavailableView(
                        "No Exercises Found",
                        systemImage: "figure.strengthtraining.traditional",
                        description: Text(
                            "Create a new exercise to get started.")
                    )
                }
            }
        }
    }

    // MARK: - View Components

    /// Builds the view for a single row in the selection list.
    private func exerciseRow(for exercise: Exercise) -> some View {
        HStack {
            Text(exercise.name)
            Spacer()
            if selectedExercises.contains(exercise) {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
            }
        }
        .contentShape(Rectangle())  // Makes the entire row tappable
        .onTapGesture {
            toggleSelection(for: exercise)
        }
    }

    // MARK: - Private Methods

    /// Toggles the presence of an exercise in the `selectedExercises` set.
    private func toggleSelection(for exercise: Exercise) {
        if selectedExercises.contains(exercise) {
            selectedExercises.remove(exercise)
        } else {
            selectedExercises.insert(exercise)
        }
    }
}
