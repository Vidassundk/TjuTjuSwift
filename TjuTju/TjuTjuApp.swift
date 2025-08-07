//
//  TjuTjuApp.swift
//  TjuTju
//
//  Created by Vidas Sun on 28/05/2025.
//
//  This is the main entry point for the application.
//

import SwiftData
import SwiftUI

@main
struct TjuTjuApp: App {

    // MARK: - SwiftData Model Container

    /// A shared, singleton instance of the ModelContainer.
    /// This container manages the app's persistent data storage.
    /// It is configured once and then injected into the view hierarchy.
    var sharedModelContainer: ModelContainer = {

        // The schema defines the complete set of model types that SwiftData will manage.
        // It's crucial that every @Model class is included here.
        let schema = Schema([
            Workout.self,
            Exercise.self,
            WorkoutExercise.self,
            ExerciseCategory.self,
            UserPreferences.self,
            ExerciseSet.self,  // This was missing and is essential for saving sets.
        ])

        // The configuration specifies how the data should be stored.
        // `isStoredInMemoryOnly: false` means the data will be saved to disk,
        // persisting between app launches.
        let modelConfiguration = ModelConfiguration(
            schema: schema, isStoredInMemoryOnly: false)

        do {
            // Attempt to create the container with the specified schema and configuration.
            return try ModelContainer(
                for: schema, configurations: [modelConfiguration])
        } catch {
            // If the container fails to initialize, it's a critical, non-recoverable error.
            // The app will terminate with a descriptive error message.
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            DashboardView()
        }
        // Injects the shared model container into the environment for all child views to access.
        .modelContainer(sharedModelContainer)
    }
}
