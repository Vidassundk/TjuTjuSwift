//
//  WorkoutManagerView.swift
//  TjuTju
//
//  Created by Vidas Sun on 02/06/2025.
//

import SwiftData
import SwiftUI

struct WorkoutManagerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var workouts: [Workout]

    var body: some View {
        List {
            ForEach(workouts) { workout in
                Section(header: Text(workout.name).font(.headline)) {
                    ForEach(workout.exercises) { workoutExercise in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(workoutExercise.exercise.name)
                                .font(.subheadline)
                                .bold()

                            ForEach(workoutExercise.sets) { set in
                                workoutSetEditor(set: set, in: workoutExercise)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    modelContext.delete(workouts[index])
                }
            }
        }
        .navigationTitle("Workout Manager")
    }

    // MARK: - Binding Helpers

    private func binding<T>(
        for set: ExerciseSet,
        in workoutExercise: WorkoutExercise,
        keyPath: WritableKeyPath<ExerciseSet, T>
    ) -> Binding<T> {
        Binding(
            get: { set[keyPath: keyPath] },
            set: { newValue in
                if let index = workoutExercise.sets.firstIndex(where: {
                    $0.id == set.id
                }) {
                    workoutExercise.sets[index][keyPath: keyPath] = newValue
                }
            }
        )
    }

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
                if let setIndex = workoutExercise.sets.firstIndex(where: {
                    $0.id == set.id
                }),
                    index < workoutExercise.sets[setIndex].values.count
                {
                    workoutExercise.sets[setIndex].values[index] = newValue
                }
            }
        )
    }

    // MARK: - Workout Set Editor

    @ViewBuilder
    private func workoutSetEditor(
        set: ExerciseSet, in workoutExercise: WorkoutExercise
    ) -> some View {
        let showReps = workoutExercise.exercise.measurements.contains {
            $0 == .weight
        }
        let repsBinding = binding(
            for: set, in: workoutExercise, keyPath: \.reps)

        VStack(alignment: .leading, spacing: 6) {
            if showReps {
                HStack {
                    Text("Reps:")
                    Stepper(
                        value: Binding(
                            get: { repsBinding.wrappedValue ?? 0 },
                            set: { repsBinding.wrappedValue = $0 }
                        ), in: 0...100
                    ) {
                        Text("\(repsBinding.wrappedValue ?? 0)")
                    }
                }
            }

            ForEach(
                Array(workoutExercise.exercise.measurements.enumerated()),
                id: \.offset
            ) { index, measurement in
                HStack {
                    Text("\(measurement.rawValue):")
                    Spacer()
                    TextField(
                        "Value",
                        value: binding(
                            for: set, in: workoutExercise, index: index),
                        format: .number
                    )
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
                }
            }
        }
        .padding(.vertical, 6)
    }
}
