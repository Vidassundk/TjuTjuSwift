import SwiftData
import SwiftUI

struct CreateWorkoutView: View {

    @ViewBuilder
    private func buildMeasurementRow(
        index: Int,
        measurement: Measurement,
        values: Binding<[Double]>
    ) -> some View {
        HStack {
            Text("\(measurement.rawValue):")
            Spacer()
            if measurement == .bodyWeight {
                Text(
                    String(format: "%.1f", userPreferences.bodyWeight ?? 0)
                )
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .trailing)
            } else {
                TextField(
                    "Value",
                    value: values[index],
                    format: .number
                )
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
            }
        }
    }

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var duration: Double = 0
    @State private var progressiveOverload: Bool = false

    @State private var isPresentingExerciseModal = false

    @Query var allExercises: [Exercise]

    @State private var selectedExercises: Set<Exercise> = []
    @State private var workoutDrafts: [WorkoutExerciseDraft] = []

    var userPreferences: UserPreferences

    var body: some View {
        Form {
            // Workout Info Section
            Section(header: Text("Workout Info")) {
                TextField("Name", text: $name)

                Stepper(value: $duration, in: 0...180, step: 5) {
                    Text("Duration: \(Int(duration)) min")
                }

                Toggle("Progressive Overload", isOn: $progressiveOverload)
            }

            Section {
                Button {
                    isPresentingExerciseModal = true
                } label: {
                    Label("", systemImage: "plus")
                        .font(.title2)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }

            // One Section per Exercise
            ForEach($workoutDrafts) { $draft in
                Section(header: Text(draft.exercise.name).font(.headline)) {
                    ForEach($draft.sets) { $set in
                        VStack(alignment: .leading, spacing: 6) {
                            if draft.exercise.measurements.contains(where: {
                                $0 == .weight
                            }) {
                                HStack {
                                    Text("Reps:")
                                    Stepper(value: $set.reps, in: 0...100) {
                                        Text("\(set.reps)")
                                    }
                                }
                            }

                            ForEach(
                                Array(draft.exercise.measurements.enumerated()),
                                id: \.offset
                            ) { index, measurement in
                                buildMeasurementRow(
                                    index: index, measurement: measurement,
                                    values: $set.values)
                            }
                        }
                        .padding(.vertical, 6)
                    }

                    Button {
                        draft.sets.append(
                            ExerciseSetDraft(
                                reps: 10,
                                values: Array(
                                    repeating: 0.0,
                                    count: draft.exercise.measurements.count)
                            )
                        )
                    } label: {
                        Label("Add Set", systemImage: "plus")
                            .font(.subheadline)
                    }
                    .padding(.top, 4)
                }
            }

            // Save Button
            Button("Save Workout") {
                let workoutExercises = workoutDrafts.map { draft in
                    let sets = draft.sets.map {
                        ExerciseSet(reps: $0.reps, values: $0.values)
                    }
                    return WorkoutExercise(exercise: draft.exercise, sets: sets)
                }

                let newWorkout = Workout(
                    name: name,
                    exercises: workoutExercises,
                    duration: duration * 60,
                    progressiveOverload: progressiveOverload
                )

                modelContext.insert(newWorkout)
                dismiss()
            }
            .disabled(name.isEmpty || workoutDrafts.isEmpty)
        }
        .navigationTitle("New Workout")
        .sheet(isPresented: $isPresentingExerciseModal) {
            ExerciseSelectionView(
                allExercises: allExercises,
                selectedExercises: $selectedExercises,
                onDismiss: {
                    syncDraftsToSelection()
                    isPresentingExerciseModal = false
                }
            )
        }
    }

    private func syncDraftsToSelection() {
        // Add new drafts
        for exercise in selectedExercises {
            if !workoutDrafts.contains(where: { $0.exercise.id == exercise.id })
            {
                workoutDrafts.append(
                    WorkoutExerciseDraft(
                        exercise: exercise,
                        sets: [
                            ExerciseSetDraft(
                                reps: 10,
                                values: Array(
                                    repeating: 0.0,
                                    count: exercise.measurements.count)
                            )
                        ]
                    )
                )
            }
        }

        // Remove drafts for deselected exercises
        workoutDrafts.removeAll { draft in
            !selectedExercises.contains(draft.exercise)
        }
    }
}

#Preview {
    let preferences = UserPreferences(bodyWeight: 72.5)
    return CreateWorkoutView(userPreferences: preferences)
        .modelContainer(
            for: [
                Workout.self, Exercise.self, WorkoutExercise.self,
                ExerciseSet.self, UserPreferences.self,
            ],
            inMemory: true
        )
}
