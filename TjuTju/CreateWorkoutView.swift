//
//  CreateWorkoutView.swift
//  TjuTju
//
//  Created by Vidas Sun on 02/06/2025.
//
//  This view allows users to construct a new workout routine by giving it a name,
//  optional settings like duration, and adding a list of exercises.
//

import SwiftData
import SwiftUI

struct CreateWorkoutView: View {
    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - Properties

    /// User-specific preferences, like body weight, passed from the parent view.
    var userPreferences: UserPreferences

    // MARK: - State

    // Workout Details
    @State private var name: String = ""
    @State private var duration: Double = 0
    @State private var hasDuration: Bool = false
    @State private var progressiveOverload: Bool = false

    // Exercise Selection
    @State private var isPresentingExerciseModal = false
    @State private var selectedExercises: Set<Exercise> = []

    /// A temporary representation of the exercises and their sets for this workout.
    /// This allows users to configure sets/reps before the workout is saved.
    @State private var workoutDrafts: [WorkoutExerciseDraft] = []

    // MARK: - Data Queries

    @Query(sort: \Exercise.name) private var allExercises: [Exercise]

    // MARK: - Computed Properties

    /// Determines if the save button should be disabled based on form validity.
    private var isSaveDisabled: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || workoutDrafts.isEmpty
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                workoutDetailsSection

                addExerciseSection

                ForEach($workoutDrafts) { $draft in
                    WorkoutDraftCard(
                        draft: $draft,
                        userPreferences: userPreferences,
                        labelProvider: self.labelFor
                    )
                }
            }
            .navigationTitle("New Workout")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: saveWorkout)
                        .disabled(isSaveDisabled)
                }
            }
            .sheet(
                isPresented: $isPresentingExerciseModal,
                onDismiss: syncDraftsToSelection
            ) {
                ExerciseSelectionView(
                    allExercises: allExercises,
                    selectedExercises: $selectedExercises,
                    onDismiss: { isPresentingExerciseModal = false }
                )
            }
        }
    }

    // MARK: - View Components

    /// A section for configuring the workout's name, duration, and progressive overload.
    private var workoutDetailsSection: some View {
        Group {
            Section("Workout Name") {
                TextField("e.g., Upper Body Strength", text: $name)
            }

            Section("Optional Settings") {
                Toggle("Set Duration", isOn: $hasDuration.animation())
                if hasDuration {
                    Stepper(value: $duration, in: 0...180, step: 5) {
                        Text("Duration: \(Int(duration)) min")
                    }
                }

                Toggle("Enable Auto-Progression", isOn: $progressiveOverload)
                if progressiveOverload {
                    Text(
                        "We will automatically increase your reps as you get stronger."
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
        }
    }

    /// A section containing the button to add exercises to the workout.
    private var addExerciseSection: some View {
        Section("Exercises") {
            Button {
                isPresentingExerciseModal = true
            } label: {
                Label("Add Exercise", systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Private Methods

    /// Provides the correct display name for a measurement, handling the special
    /// case where "Weight" should be displayed as "Extra Weight".
    private func labelFor(_ measurement: Measurement, in context: [Measurement])
        -> String
    {
        if measurement == .weight && context.contains(.bodyWeight) {
            return "Extra Weight"
        }
        return measurement.rawValue
    }

    /// Synchronizes the `workoutDrafts` array with the `selectedExercises` set.
    /// It adds new drafts for newly selected exercises and removes drafts for deselected ones.
    private func syncDraftsToSelection() {
        // Add drafts for exercises that are in `selectedExercises` but not yet in `workoutDrafts`.
        for exercise in selectedExercises
        where !workoutDrafts.contains(where: { $0.exercise == exercise }) {
            let newDraft = WorkoutExerciseDraft(
                exercise: exercise,
                sets: [
                    // Start with one default set.
                    ExerciseSetDraft(
                        reps: 10,
                        values: Array(
                            repeating: 0.0, count: exercise.measurements.count)
                    )
                ]
            )
            workoutDrafts.append(newDraft)
        }

        // Remove drafts for exercises that are no longer in `selectedExercises`.
        workoutDrafts.removeAll { draft in
            !selectedExercises.contains(draft.exercise)
        }
    }

    /// Converts the temporary workout drafts into persistent SwiftData models and saves the workout.
    private func saveWorkout() {
        let workoutExercises = workoutDrafts.map { draft in
            let sets = draft.sets.map { setDraft in
                ExerciseSet(reps: setDraft.reps, values: setDraft.values)
            }
            return WorkoutExercise(exercise: draft.exercise, sets: sets)
        }

        let newWorkout = Workout(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            exercises: workoutExercises,
            duration: hasDuration ? (duration * 60) : nil,  // Store duration in seconds
            progressiveOverload: progressiveOverload
        )

        modelContext.insert(newWorkout)
        dismiss()
    }
}

#Preview {
    // Create a dummy UserPreferences object for the preview.
    let preferences = UserPreferences(bodyWeight: 72.5)

    return CreateWorkoutView(userPreferences: preferences)
        .modelContainer(for: [Workout.self, Exercise.self], inMemory: true)
}
