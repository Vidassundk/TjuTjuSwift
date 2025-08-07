//
//  ManageCategoriesView.swift
//  TjuTju
//
//  Created by Vidas Sun on 02/06/2025.
//
//  A view for creating and deleting exercise categories.
//  It's typically presented as a sheet.
//

import SwiftData
import SwiftUI

struct ManageCategoriesView: View {
    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - Data Queries

    /// Fetches all categories, sorted alphabetically for a consistent UI.
    @Query(sort: \ExerciseCategory.name) private var categories:
        [ExerciseCategory]

    // MARK: - State

    @State private var newCategoryName: String = ""

    // MARK: - Computed Properties

    /// Determines if the 'Add' button should be disabled.
    private var isAddDisabled: Bool {
        let trimmedName = newCategoryName.trimmingCharacters(
            in: .whitespacesAndNewlines)
        // Disable if the name is empty or if a category with the same name already exists (case-insensitive).
        return trimmedName.isEmpty
            || categories.contains {
                $0.name.caseInsensitiveCompare(trimmedName) == .orderedSame
            }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List {
                Section("Add New Category") {
                    HStack {
                        TextField("e.g., Back, Core", text: $newCategoryName)
                        Button("Add", action: addCategory)
                            .disabled(isAddDisabled)
                    }
                }

                Section("Your Categories") {
                    ForEach(categories) { category in
                        Text(category.name)
                    }
                    .onDelete(perform: deleteCategories)
                }
            }
            .navigationTitle("Manage Categories")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .overlay {
                if categories.isEmpty {
                    ContentUnavailableView(
                        "No Categories",
                        systemImage: "tag.slash",
                        description: Text("Add a category to get started.")
                    )
                }
            }
        }
    }

    // MARK: - Private Methods

    /// Creates a new category from the text field's content,
    /// inserts it into the model context, and clears the text field.
    private func addCategory() {
        let trimmedName = newCategoryName.trimmingCharacters(
            in: .whitespacesAndNewlines)

        // A final guard, although the button is disabled, this provides extra safety.
        guard !trimmedName.isEmpty else { return }

        let newCategory = ExerciseCategory(name: trimmedName)
        modelContext.insert(newCategory)

        // Clear the input field for the next entry.
        newCategoryName = ""
    }

    /// Deletes categories from the model context at the specified offsets.
    /// This is called by the swipe-to-delete gesture.
    private func deleteCategories(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(categories[index])
        }
    }
}

#Preview {
    ManageCategoriesView()
        .modelContainer(for: [ExerciseCategory.self], inMemory: true)
}
