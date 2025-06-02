//
//  CreateExerciseView.swift
//  TjuTju
//
//  Created by Vidas Sun on 02/06/2025.
//

import SwiftData
import SwiftUI

struct CreateExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var selectedMeasurements: Set<Measurement> = []
    @State private var customCategory: String = ""

    @State private var isPresentingCategoryModal = false
    @Query var allCategories: [ExerciseCategory]
    @State private var selectedCategories: Set<ExerciseCategory> = []

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Name")) {
                    TextField("Exercise name", text: $name)
                }

                Section(header: Text("Measurements")) {
                    ForEach(Measurement.allCases, id: \.self) { measurement in
                        MultipleSelectionRow(
                            title: measurement.rawValue,
                            isSelected: selectedMeasurements.contains(
                                measurement)
                        ) {
                            if selectedMeasurements.contains(measurement) {
                                selectedMeasurements.remove(measurement)
                            } else {
                                selectedMeasurements.insert(measurement)
                            }
                        }
                    }
                }

                Section(header: Text("Body Categories")) {
                    if allCategories.isEmpty {
                        Text("No categories yet")
                    } else {
                        ForEach(allCategories) { category in
                            MultipleSelectionRow(
                                title: category.name,
                                isSelected: selectedCategories.contains(
                                    category)
                            ) {
                                if selectedCategories.contains(category) {
                                    selectedCategories.remove(category)
                                } else {
                                    selectedCategories.insert(category)
                                }
                            }
                        }
                    }

                    Button {
                        isPresentingCategoryModal = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Manage Categories")
                        }
                    }
                }

            }
            .navigationTitle("New Exercise")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let category = ExerciseCategory(name: customCategory)
                        let newExercise = Exercise(
                            name: name,
                            exerciseCategories: [category],
                            measurements: Array(selectedMeasurements)
                        )
                        modelContext.insert(newExercise)
                        dismiss()
                    }
                    .disabled(name.isEmpty || selectedMeasurements.isEmpty)
                }
            }
        }.sheet(isPresented: $isPresentingCategoryModal) {
            ManageCategoriesView()
        }

    }
}

// Helper for checkmark rows
struct MultipleSelectionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

#Preview {
    CreateExerciseView()
        .modelContainer(for: [Workout.self, Exercise.self], inMemory: true)
}
