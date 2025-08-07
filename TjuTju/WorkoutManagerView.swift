//
//  WorkoutManagerView.swift
//  TjuTju
//
//  Created by Vidas Sun on 02/06/2025.
//
//  This view displays a list of all saved workouts, allowing users to
//  view and edit the sets and values for each exercise directly.
//

import SwiftData
import SwiftUI

struct WorkoutManagerView: View {
    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext

    // MARK: - Data Queries

    /// Fetches all workouts, sorted alphabetically by name.
    @Query(sort: \Workout.name) private var workouts: [Workout]

    /// Fetches the user's preferences to display body weight correctly.
    @Query private var userPreferences: [UserPreferences]

    // MARK: - Body

    var body: some View {
        List {
            ForEach(workouts) { workout in
                workoutSection(for: workout)
            }
            .onDelete(perform: deleteWorkouts)
        }
        .navigationTitle("Workout Manager")
        .overlay {
            if workouts.isEmpty {
                ContentUnavailableView(
                    "No Workouts Found",
                    systemImage: "list.bullet.clipboard",
                    description: Text(
                        "Create a workout from the Dashboard to see it here.")
                )
            }
        }
    }

    // MARK: - View Components

    /// Builds the entire section for a single workout, including its header and list of exercises.
    private func workoutSection(for workout: Workout) -> some View {
        Section {
            ForEach(workout.exercises) { workoutExercise in
                VStack(alignment: .leading, spacing: 8) {
                    Text(workoutExercise.exercise.name)
                        .font(.subheadline)
                        .bold()

                    ForEach(workoutExercise.sets) { set in
                        workoutSetEditor(
                            set: set,
                            in: workoutExercise,
                            preferences: userPreferences.first
                        )
                    }
                }
                .padding(.vertical, 6)
            }
        } header: {
            workoutHeader(for: workout)
        }
    }

    /// Builds the header view for a workout section.
    private func workoutHeader(for workout: Workout) -> some View {
        HStack {
            Text(workout.name)
                .font(.headline)
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                if let duration = workout.duration, duration > 0 {
                    Label("\(Int(duration / 60)) min", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                if workout.progressiveOverload {
                    Label(
                        "Auto-Progress",
                        systemImage: "chart.line.uptrend.xyaxis"
                    )
                    .font(.caption)
                    .foregroundColor(.accentColor)
                }
            }
        }
    }

    /// Builds the editor UI for a single exercise set.
    @ViewBuilder
    private func workoutSetEditor(
        set: ExerciseSet,
        in workoutExercise: WorkoutExercise,
        preferences: UserPreferences?
    ) -> some View {
        let showReps = workoutExercise.exercise.measurements.contains {
            $0 == .weight || $0 == .bodyWeight
        }

        VStack(alignment: .leading, spacing: 6) {
            if showReps {
                HStack {
                    Text("Reps:")
                    Stepper(
                        value: binding(
                            for: set, in: workoutExercise, keyPath: \.reps,
                            defaultValue: 0),
                        in: 0...100
                    ) {
                        Text("\(set.reps ?? 0)")
                    }
                }
            }

            ForEach(
                Array(workoutExercise.exercise.measurements.enumerated()),
                id: \.offset
            ) { index, measurement in
                measurementRow(
                    for: measurement,
                    at: index,
                    in: workoutExercise,
                    set: set,
                    preferences: preferences
                )
            }
        }
        .padding(.vertical, 6)
    }

    /// Builds a single row for a measurement within the set editor.
    @ViewBuilder
    private func measurementRow(
        for measurement: Measurement,
        at index: Int,
        in workoutExercise: WorkoutExercise,
        set: ExerciseSet,
        preferences: UserPreferences?
    ) -> some View {
        HStack {
            Text(
                "\(labelFor(measurement, in: workoutExercise.exercise.measurements)):"
            )
            Spacer()

            if measurement == .bodyWeight {
                Text(String(format: "%.1f", preferences?.bodyWeight ?? 0))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            } else {
                TextField(
                    "Value",
                    value: binding(for: set, in: workoutExercise, index: index),
                    format: .number
                )
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
            }
        }
    }

    // MARK: - Private Methods

    /// Provides the correct display name for a measurement.
    private func labelFor(_ measurement: Measurement, in context: [Measurement])
        -> String
    {
        if measurement == .weight && context.contains(.bodyWeight) {
            return "Extra Weight"
        }
        return measurement.rawValue
    }

    /// Deletes workouts from the model context at the specified offsets.
    private func deleteWorkouts(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(workouts[index])
        }
    }

    // MARK: - Binding Helpers

    /// Creates a writeable binding to an optional property of a value type (like ExerciseSet)
    /// that is nested inside a SwiftData model's array. This helper returns a non-optional
    /// binding by using a default value, making it compatible with UI controls like Stepper.
    private func binding<T>(
        for set: ExerciseSet,
        in workoutExercise: WorkoutExercise,
        keyPath: WritableKeyPath<ExerciseSet, T?>,
        defaultValue: T
    ) -> Binding<T> {
        Binding(
            get: { set[keyPath: keyPath] ?? defaultValue },
            set: { newValue in
                if let index = workoutExercise.sets.firstIndex(where: {
                    $0.id == set.id
                }) {
                    workoutExercise.sets[index][keyPath: keyPath] = newValue
                }
            }
        )
    }

    /// A specialized binding helper for the `values` array within an ExerciseSet.
    /// It safely gets and sets the double value at a specific index.
    private func binding(
        for set: ExerciseSet,
        in workoutExercise: WorkoutExercise,
        index: Int
    ) -> Binding<Double> {
        Binding(
            get: {
                guard index < set.values.count else { return 0.0 }
                return set.values[index]
            },
            set: { newValue in
                guard
                    let setIndex = workoutExercise.sets.firstIndex(where: {
                        $0.id == set.id
                    }),
                    index < workoutExercise.sets[setIndex].values.count
                else { return }

                workoutExercise.sets[setIndex].values[index] = newValue
            }
        )
    }
}

#Preview {
    NavigationStack {
        WorkoutManagerView()
            .modelContainer(
                for: [Workout.self, UserPreferences.self], inMemory: true)
    }
}
