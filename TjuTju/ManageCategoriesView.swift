//
//  ManageCategoriesView.swift
//  TjuTju
//
//  Created by Vidas Sun on 02/06/2025.
//

import SwiftData
import SwiftUI

struct ManageCategoriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query var categories: [ExerciseCategory]
    @State private var newCategoryName: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Add New Category")) {
                    TextField("e.g. Back, Core", text: $newCategoryName)
                    Button("Add") {
                        guard !newCategoryName.isEmpty else { return }
                        let newCategory = ExerciseCategory(
                            name: newCategoryName)
                        modelContext.insert(newCategory)
                        newCategoryName = ""
                    }
                }

                Section(header: Text("Your Categories")) {
                    ForEach(categories) { category in
                        HStack {
                            Text(category.name)
                            Spacer()
                            Button(role: .destructive) {
                                modelContext.delete(category)
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Manage Categories")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
