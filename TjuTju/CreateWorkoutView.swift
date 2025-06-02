import SwiftData
import SwiftUI

struct CreateWorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var duration: Double = 0
    @State private var progressiveOverload: Bool = false

    @State private var isPresentingExerciseModal = false

    @Query var allExercises: [Exercise]

    @State private var selectedExercises: Set<Exercise> = []
    @State private var workoutDrafts: [WorkoutExerciseDraft] = []

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

            // Exercise Selection Section
            Section(header: Text("Select Exercises")) {
                Button {
                    isPresentingExerciseModal = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add your first exercise")
                    }
                    .foregroundColor(.blue)
                }

                ForEach(allExercises) { exercise in
                    HStack {
                        Text(exercise.name)
                        Spacer()
                        if selectedExercises.contains(exercise) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if selectedExercises.contains(exercise) {
                            selectedExercises.remove(exercise)
                        } else {
                            selectedExercises.insert(exercise)
                        }
                        syncDraftsToSelection()
                    }
                }
            }

            // One Section per Exercise
            ForEach($workoutDrafts) { $draft in
                Section(header: Text(draft.exercise.name).font(.headline)) {
                    ForEach($draft.sets) { $set in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Reps:")
                                Stepper(value: $set.reps, in: 0...100) {
                                    Text("\(set.reps)")
                                }
                            }

                            ForEach(
                                Array(draft.exercise.measurements.enumerated()),
                                id: \.offset
                            ) { index, measurement in
                                HStack {
                                    Text("\(measurement.rawValue):")
                                    Spacer()
                                    TextField(
                                        "Value", value: $set.values[index],
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
            CreateExerciseView()
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
    CreateWorkoutView()
        .modelContainer(
            for: [
                Workout.self, Exercise.self, WorkoutExercise.self,
                ExerciseSet.self,
            ],
            inMemory: true
        )
}
