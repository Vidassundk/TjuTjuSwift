//
//  EditExerciseView.swift
//  TjuTju
//
//  Created by Vidas Sun on 02/06/2025.
//
//  This view provides a form for modifying an existing exercise.
//  Changes are saved automatically to the model thanks to the @Bindable wrapper.
//

import SwiftData
import SwiftUI

struct EditExerciseView: View {
    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Properties

    /// The exercise being edited. The @Bindable wrapper ensures that any
    /// changes made in this view are directly written back to the model.
    @Bindable var exercise: Exercise

    // MARK: - State

    @State private var isPresentingCategoryModal = false

    // MARK: - Data Queries

    @Query(sort: \ExerciseCategory.name) private var allCategories:
        [ExerciseCategory]

    // MARK: - Computed Properties

    /// Determines whether the done button should be disabled.
    private var isDoneDisabled: Bool {
        exercise.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || exercise.measurements.isEmpty
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Exercise name", text: $exercise.name)
                }

                Section("Measurements to Track") {
                    ForEach(Measurement.allCases, id: \.self) { measurement in
                        MultipleSelectionRow(
                            title: measurement.rawValue,
                            isSelected: exercise.measurements.contains(
                                measurement)
                        ) {
                            toggleSelection(
                                for: measurement, in: &exercise.measurements)
                        }
                    }
                }

                Section("Body Categories") {
                    ForEach(allCategories) { category in
                        MultipleSelectionRow(
                            title: category.name,
                            isSelected: exercise.exerciseCategories.contains(
                                category)
                        ) {
                            toggleSelection(
                                for: category, in: &exercise.exerciseCategories)
                        }
                    }

                    Button {
                        isPresentingCategoryModal = true
                    } label: {
                        Label("Manage Categories", systemImage: "plus.circle")
                    }
                }
            }
            .navigationTitle("Edit Exercise")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .disabled(isDoneDisabled)
                }
            }
            .sheet(isPresented: $isPresentingCategoryModal) {
                ManageCategoriesView()
            }
        }
    }

    // MARK: - Private Methods

    /// Toggles the presence of an item in an array that functions like a set.
    private func toggleSelection<T: Hashable>(
        for item: T, in collection: inout [T]
    ) {
        if let index = collection.firstIndex(of: item) {
            collection.remove(at: index)
        } else {
            collection.append(item)
        }
    }
}
