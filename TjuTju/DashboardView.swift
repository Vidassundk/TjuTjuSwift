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

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text(
                    workouts.count > 0
                        ? "You have \(workouts.count) workouts"
                        : "You have no workouts"
                )

                NavigationLink("Create a new workout") {
                    CreateWorkoutView()
                }
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
            .padding()
            .navigationTitle("Dashboard")
        }
    }
}

#Preview {
    DashboardView().modelContainer(for: Workout.self, inMemory: true)
}
