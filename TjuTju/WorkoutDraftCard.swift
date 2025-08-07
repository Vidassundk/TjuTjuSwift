//
//  WorkoutDraftCard.swift
//  TjuTju
//
//  Created by Vidas Sun on 18/06/2025.
//
//  A view component that displays a single exercise within a workout draft.
//  It allows for the configuration of sets, including reps and measurement values.
//

import SwiftUI

struct WorkoutDraftCard: View {
    // MARK: - Properties

    @Binding var draft: WorkoutExerciseDraft
    let userPreferences: UserPreferences

    /// A closure passed from the parent view to determine the correct label for a measurement
    /// (e.g., handling the "Weight" vs. "Extra Weight" case).
    let labelProvider: (Measurement, [Measurement]) -> String

    // MARK: - Body

    var body: some View {
        Section(header: Text(draft.exercise.name).font(.headline)) {
            // Loop through each set, enabling swipe-to-delete.
            ForEach($draft.sets) { $set in
                setRow(for: $set)
            }
            .onDelete(perform: deleteSet)

            // "Add Set" Button
            Button(action: addSet) {
                Label("Add Set", systemImage: "plus")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.top, 4)
        }
    }

    // MARK: - View Components

    /// Builds the view for a single configurable set.
    private func setRow(for set: Binding<ExerciseSetDraft>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Reps Stepper
            HStack {
                Text("Reps:")
                Spacer()
                Stepper(value: set.reps, in: 0...100) {
                    Text("\(set.wrappedValue.reps)")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }

            // Loop through each measurement for the set (e.g., Weight, Distance)
            ForEach(
                Array(draft.exercise.measurements.enumerated()), id: \.offset
            ) { index, measurement in
                measurementRow(
                    for: measurement,
                    at: index,
                    in: draft.exercise.measurements,
                    values: set.values
                )
            }
        }
        .padding(.vertical, 6)
    }

    /// Builds a single row for a measurement like Weight or Distance.
    @ViewBuilder
    private func measurementRow(
        for measurement: Measurement,
        at index: Int,
        in context: [Measurement],
        values: Binding<[Double]>
    ) -> some View {
        HStack {
            Text("\(labelProvider(measurement, context)):")
            Spacer()

            if measurement == .bodyWeight {
                Text(String(format: "%.1f", userPreferences.bodyWeight ?? 0))
                    .foregroundColor(.gray)
            } else {
                TextField("Value", value: values[index], format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
        }
    }

    // MARK: - Private Methods

    /// Adds a new default set to the exercise draft.
    private func addSet() {
        let newSet = ExerciseSetDraft(
            reps: 10,
            values: Array(
                repeating: 0.0,
                count: draft.exercise.measurements.count
            )
        )
        draft.sets.append(newSet)
    }

    /// Deletes sets from the draft at the specified offsets.
    private func deleteSet(at offsets: IndexSet) {
        draft.sets.remove(atOffsets: offsets)
    }
}

#Preview {
    // Create mock data for the preview.
    struct PreviewWrapper: View {
        @State private var draft = WorkoutExerciseDraft(
            exercise: Exercise(
                name: "Barbell Bench Press",
                exerciseCategories: [],
                measurements: [.weight]
            ),
            sets: [
                ExerciseSetDraft(reps: 8, values: [50.0]),
                ExerciseSetDraft(reps: 10, values: [45.0]),
            ]
        )

        let prefs = UserPreferences(bodyWeight: 75.0)

        func labelProvider(_ m: Measurement, _ c: [Measurement]) -> String {
            m.rawValue
        }

        var body: some View {
            Form {
                WorkoutDraftCard(
                    draft: $draft,
                    userPreferences: prefs,
                    labelProvider: labelProvider
                )
            }
        }
    }

    return PreviewWrapper()
}
