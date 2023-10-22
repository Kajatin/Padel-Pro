//
//  WorkoutManager+watchOS.swift
//  Padel Pro Watch App
//
//  Created by Roland Kajatin on 22/10/2023.
//

import OSLog
import HealthKit
import Foundation

// MARK: - Workout Session Management

extension WorkoutManager {
    /// Use healthStore.requestAuthorization to request authorization in watchOS when healthDataAccessRequest isn't available yet
    func requestAuthorization() {
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
            } catch {
                Logger.shared.error("Failed to request HealthKit authorization: \(error)")
            }
        }
    }
    
    func startWorkout(workoutConfiguration: HKWorkoutConfiguration) async throws {
        Logger.shared.debug("Called \(#function)")
        
        // Create the session and obtain the workout builder.
        Logger.shared.debug("Creating session with configuration: \(String(describing: workoutConfiguration))")
        session = try HKWorkoutSession(healthStore: healthStore, configuration: workoutConfiguration)
        builder = session?.associatedWorkoutBuilder()
        
        // Assign delegates.
        session?.delegate = self
        builder?.delegate = self
        
        // Set the workout builder's data source.
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: workoutConfiguration)
        
        // Start the workout session activity.
        let startDate = Date()
        session?.startActivity(with: startDate)
        try await builder?.beginCollection(at: startDate)
    }
}

// MARK: - Live Workout Builder Delegate

// HealthKit calls the delegate methods on an anonymous serial background queue,
// so the methods need to be nonisolated explicitly.
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    /// Tells the delegate that new data has been added to the builder
    nonisolated func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder,
                                    didCollectDataOf collectedTypes: Swift.Set<HKSampleType>) {
        Task { @MainActor in
            var allStatistics: [HKStatistics] = []
            
            for type in collectedTypes {
                if let quantityType = type as? HKQuantityType, let statistics = workoutBuilder.statistics(for: quantityType) {
                    updateForStatistics(statistics)
                    allStatistics.append(statistics)
                }
            }
        }
    }
    
    /// Tells the delegate that a new event has been added to the builder
    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
    }
}
