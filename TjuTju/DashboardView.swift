//
//  DashboardView.swift
//  TjuTju
//
//  Created by Vidas Sun on 28/05/2025.
//
//  The main screen of the application, providing navigation to core features
//  and allowing users to manage their profile settings.
//

import SwiftData
import SwiftUI

struct DashboardView: View {
    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext

    // MARK: - Data Queries

    @Query private var workouts: [Workout]
    @Query private var preferences: [UserPreferences]

    // MARK: - State

    /// Holds the active user preferences object. It's optional because it's loaded asynchronously.
    @State private var userPreferences: UserPreferences?

    /// Controls the visibility of the confirmation alert for deleting all workouts.
    @State private var isShowingDeleteConfirmation = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                summarySection
                actionsSection

                // Only show the profile section if the preferences have been loaded.
                if let prefs = userPreferences {
                    profileSection(for: prefs)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Dashboard")
            .onAppear(perform: setupUserPreferences)
            .alert("Are you sure?", isPresented: $isShowingDeleteConfirmation) {
                Button(
                    "Delete All Workouts", role: .destructive,
                    action: deleteAllWorkouts)
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }

    // MARK: - View Components

    private var summarySection: some View {
        Section {
            Text(
                workouts.isEmpty
                    ? "You have no saved workouts."
                    : "You have \(workouts.count) workout\(workouts.count == 1 ? "" : "s")."
            )
        }
    }

    private var actionsSection: some View {
        Section("Actions") {
            // NavigationLink is disabled until userPreferences are loaded.
            NavigationLink("Create New Workout") {
                // Safely unwrap the optional userPreferences.
                // The link is disabled if this is nil, but this prevents any potential
                // crashes from SwiftUI pre-loading the destination view.
                if let prefs = userPreferences {
                    CreateWorkoutView(userPreferences: prefs)
                }
            }
            .disabled(userPreferences == nil)

            NavigationLink("View Workouts") {
                WorkoutManagerView()
            }

            NavigationLink("Manage Exercises") {
                ExerciseManagerView()
            }

            // This button only shows if there are workouts to delete.
            if !workouts.isEmpty {
                Button("Remove All Workouts", role: .destructive) {
                    isShowingDeleteConfirmation = true
                }
            }
        }
    }

    private func profileSection(for prefs: UserPreferences) -> some View {
        Section("Your Profile") {
            HStack {
                // Safely unwrap the optional `preferredUnitSystem` with a default value.
                Text(
                    "Bodyweight (\((prefs.preferredUnitSystem ?? .metric).label))"
                )
                Spacer()
                TextField(
                    (prefs.preferredUnitSystem ?? .metric).label,
                    value: $userPreferences.bodyWeight, format: .number
                )
                .keyboardType(.decimalPad)
                .frame(width: 80)
                .multilineTextAlignment(.trailing)
            }

            Picker(
                "Unit System", selection: $userPreferences.preferredUnitSystem
            ) {
                ForEach(UnitSystem.allCases, id: \.self) { unit in
                    Text(unit.label).tag(unit)
                }
            }
        }
    }

    // MARK: - Private Methods

    /// Ensures a single `UserPreferences` object exists in the database.
    /// If one exists, it's loaded into state. If not, a new default one is created and loaded.
    /// This is called only once when the view appears.
    private func setupUserPreferences() {
        if let existingPreferences = preferences.first {
            userPreferences = existingPreferences
        } else {
            let newPreferences = UserPreferences()
            modelContext.insert(newPreferences)
            userPreferences = newPreferences
        }
    }

    /// Deletes all `Workout` objects from the SwiftData context.
    private func deleteAllWorkouts() {
        for workout in workouts {
            modelContext.delete(workout)
        }
    }
}

// MARK: - Binding Extensions
// These extensions simplify creating bindings to the optional userPreferences state.

extension Binding where Value == UserPreferences? {
    fileprivate var bodyWeight: Binding<Double> {
        // Provides a binding directly to the bodyWeight, defaulting to 0 if nil.
        Binding<Double>(
            get: { self.wrappedValue?.bodyWeight ?? 0 },
            set: { self.wrappedValue?.bodyWeight = $0 }
        )
    }

    fileprivate var preferredUnitSystem: Binding<UnitSystem> {
        // Provides a binding directly to the unit system, defaulting to .metric if nil.
        Binding<UnitSystem>(
            get: { self.wrappedValue?.preferredUnitSystem ?? .metric },
            set: { self.wrappedValue?.preferredUnitSystem = $0 }
        )
    }
}

#Preview {
    DashboardView()
        .modelContainer(
            for: [Workout.self, UserPreferences.self], inMemory: true)
}
