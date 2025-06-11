//
//  DashboardView.swift
//  TjuTju
//
//  Created by Vidas Sun on 28/05/2025.
//

import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var workouts: [Workout]

    @Query var preferences: [UserPreferences]
    @State private var userPreferences: UserPreferences?

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text(
                        workouts.count > 0
                            ? "You have \(workouts.count) workouts"
                            : "You have no workouts"
                    )

                    NavigationLink("Create a new workout") {
                        if let prefs = userPreferences {
                            CreateWorkoutView(userPreferences: prefs)
                        } else {
                            Text("Loading...")
                        }
                    }
                    .disabled(userPreferences == nil)

                    NavigationLink("View Workouts") {
                        WorkoutManagerView()
                    }

                    NavigationLink("Manage Exercises") {
                        ExerciseManagerView()
                    }

                    Button(role: .destructive) {
                        for workout in workouts {
                            modelContext.delete(workout)
                        }
                    } label: {
                        Text("Remove all workouts")
                    }
                }

                if let prefs = userPreferences {
                    Section("Your Profile") {
                        HStack {
                            Text(
                                "Bodyweight (\(prefs.preferredUnitSystem == .imperial ? "lbs" : "kg"))"
                            )
                            Spacer()
                            TextField(
                                prefs.preferredUnitSystem == .imperial
                                    ? "lbs" : "kg",
                                value: Binding(
                                    get: { prefs.bodyWeight ?? 0 },
                                    set: { prefs.bodyWeight = $0 }
                                ),
                                format: .number
                            )
                            .keyboardType(.decimalPad)
                            .frame(width: 80)
                            .multilineTextAlignment(.trailing)
                        }

                        Picker(
                            "Unit System",
                            selection: Binding(
                                get: { prefs.preferredUnitSystem },
                                set: { prefs.preferredUnitSystem = $0 }
                            )
                        ) {
                            ForEach(UnitSystem.allCases, id: \.self) { unit in
                                Text(unit.label).tag(unit)
                            }
                        }
                    }

                }

            }
            .formStyle(.grouped)  // ⬅️ Adds nice insets + fills screen
            .navigationTitle("Dashboard")
        }.onAppear {
            if userPreferences == nil {
                if let existing = preferences.first {
                    userPreferences = existing
                } else {
                    let new = UserPreferences()
                    modelContext.insert(new)
                    userPreferences = new
                }
            }
        }
    }

}

#Preview {
    DashboardView()
        .modelContainer(
            for: [Workout.self, UserPreferences.self],
            inMemory: true
        )
}
