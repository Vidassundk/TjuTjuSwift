//
//  CreateExerciseView.swift
//  TjuTju
//
//  Created by Vidas Sun on 02/06/2025.
//
//  This view provides a form for users to define a new exercise,
//  including its name, the metrics to track (measurements), and
//  its associated body part categories.
//

import SwiftData
import SwiftUI

struct CreateExerciseView: View {
    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    @State private var name: String = ""
    @State private var selectedMeasurements: Set<Measurement> = []
    @State private var selectedCategories: Set<ExerciseCategory> = []

    @State private var isPresentingCategoryModal = false

    // MARK: - Data Queries

    @Query(sort: \ExerciseCategory.name) private var allCategories:
        [ExerciseCategory]

    // MARK: - Computed Properties

    /// Determines whether the save button should be disabled.
    /// The form is considered invalid if the name is empty or no measurements are selected.
    private var isSaveDisabled: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || selectedMeasurements.isEmpty
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("e.g., Barbell Bench Press", text: $name)
                }

                Section("Measurements to Track") {
                    ForEach(Measurement.allCases, id: \.self) { measurement in
                        MultipleSelectionRow(
                            title: measurement.rawValue,
                            isSelected: selectedMeasurements.contains(
                                measurement)
                        ) {
                            toggleSelection(
                                for: measurement, in: &selectedMeasurements)
                        }
                    }
                }

                Section("Body Categories") {
                    // Display existing categories for selection.
                    ForEach(allCategories) { category in
                        MultipleSelectionRow(
                            title: category.name,
                            isSelected: selectedCategories.contains(category)
                        ) {
                            toggleSelection(
                                for: category, in: &selectedCategories)
                        }
                    }

                    // Button to navigate to the category management screen.
                    Button {
                        isPresentingCategoryModal = true
                    } label: {
                        Label("Manage Categories", systemImage: "plus.circle")
                    }
                }
            }
            .navigationTitle("New Exercise")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel, action: { dismiss() })
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: saveExercise)
                        .disabled(isSaveDisabled)
                }
            }
            .sheet(isPresented: $isPresentingCategoryModal) {
                ManageCategoriesView()
            }
        }
    }

    // MARK: - Private Methods

    /// Toggles the presence of an item in a Set.
    /// If the item exists, it's removed. If it doesn't, it's inserted.
    /// - Parameters:
    ///   - item: The hashable item to toggle.
    ///   - selection: A binding to the set containing the items.
    private func toggleSelection<T: Hashable>(
        for item: T, in selection: inout Set<T>
    ) {
        if selection.contains(item) {
            selection.remove(item)
        } else {
            selection.insert(item)
        }
    }

    /// Validates the form data, creates a new Exercise object,
    /// inserts it into the model context, and dismisses the view.
    private func saveExercise() {
        let newExercise = Exercise(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            exerciseCategories: Array(selectedCategories),
            measurements: Array(selectedMeasurements)
        )

        modelContext.insert(newExercise)

        // SwiftData automatically saves changes, so we just need to dismiss.
        dismiss()
    }
}

#Preview {
    CreateExerciseView()
        .modelContainer(
            for: [Exercise.self, ExerciseCategory.self], inMemory: true)
}
