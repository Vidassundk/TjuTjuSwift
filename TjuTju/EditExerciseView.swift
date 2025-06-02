//
//  EditExerciseView.swift
//  TjuTju
//
//  Created by Vidas Sun on 02/06/2025.
//

import SwiftData
import SwiftUI

struct EditExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var exercise: Exercise

    @Query var allCategories: [ExerciseCategory]
    @State private var selectedMeasurements: Set<Measurement> = []
    @State private var selectedCategories: Set<ExerciseCategory> = []

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Name")) {
                    TextField("Exercise name", text: $exercise.name)
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

                Section(header: Text("Categories")) {
                    ForEach(allCategories) { category in
                        MultipleSelectionRow(
                            title: category.name,
                            isSelected: selectedCategories.contains(category)
                        ) {
                            if selectedCategories.contains(category) {
                                selectedCategories.remove(category)
                            } else {
                                selectedCategories.insert(category)
                            }
                        }
                    }
                }
            }
            .onAppear {
                selectedMeasurements = Set(exercise.measurements)
                selectedCategories = Set(exercise.exerciseCategories)
            }
            .navigationTitle("Edit Exercise")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        exercise.measurements = Array(selectedMeasurements)
                        exercise.exerciseCategories = Array(selectedCategories)
                        dismiss()
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
    }
}
