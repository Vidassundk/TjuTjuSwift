import SwiftUI

struct ExerciseSelectionView: View {
    let allExercises: [Exercise]
    @Binding var selectedExercises: Set<Exercise>
    var onDismiss: () -> Void

    @State private var isPresentingNewExercise = false

    var body: some View {
        NavigationStack {
            VStack {
                Button {
                    isPresentingNewExercise = true
                } label: {
                    Label("New Custom Exercise", systemImage: "plus.circle")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical)
                }

                List {
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
                        }
                    }
                }
            }
            .navigationTitle("Select Exercises")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
            .sheet(isPresented: $isPresentingNewExercise) {
                CreateExerciseView()
            }
        }
    }
}
