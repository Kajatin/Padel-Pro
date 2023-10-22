//
//  AppDelegate.swift
//  Padel Pro Watch App
//
//  Created by Roland Kajatin on 14/10/2023.
//

import OSLog
import SwiftUI
import WatchKit
import HealthKit

class AppDelegate: NSObject, WKApplicationDelegate {
    
    /// Tells the delegate that the user started a workout session on the paired iPhone.
    func handle(_ workoutConfiguration: HKWorkoutConfiguration) {
        Task {
            do {
                WorkoutManager.shared.reset()
                try await WorkoutManager.shared.startWorkout(workoutConfiguration: workoutConfiguration)
                Logger.shared.debug("Successfully started workout.")
            } catch {
                Logger.shared.error("Failed to start workout.")
            }
        }
    }
    
    /// Tells the delegate when the app relaunches after crashing during an active workout session.
    func handleActiveWorkoutRecovery() {
        Task {
            do {
                let recoveredSession = try await WorkoutManager.shared.healthStore.recoverActiveWorkoutSession()
                WorkoutManager.shared.builder = recoveredSession?.associatedWorkoutBuilder()
                
                // Assign delegates.
                WorkoutManager.shared.session?.delegate = WorkoutManager.shared
                WorkoutManager.shared.builder?.delegate = WorkoutManager.shared
            } catch {
                Logger.shared.error("Failed to recover workout after crash.")
            }
        }
    }
}
