//
//  WorkoutManager+iOS.swift
//  Padel Pro
//
//  Created by Roland Kajatin on 14/10/2023.
//

import OSLog
import HealthKit
import Foundation

// MARK: - Workout Session Management

extension WorkoutManager {
    func startWatchWorkout() async throws {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .tennis
        configuration.locationType = .outdoor //indoors == .indoors ? .indoor : .outdoor
        try await healthStore.startWatchApp(toHandle: configuration)
    }
    
    func retrieveRemoteSession() {
        Logger.shared.debug("Called \(#function)")
        /// HealthKit calls this handler when a session starts mirroring.
        healthStore.workoutSessionMirroringStartHandler = { mirroredSession in
            Task { @MainActor in
                Logger.shared.debug("Got remote session: \(mirroredSession)")
                self.reset()
                self.session = mirroredSession
                self.session?.delegate = self
                Logger.shared.debug("Start mirroring remote session: \(mirroredSession)")
            }
        }
    }
    
    func handleReceivedData(_ data: Data) throws {
        Logger.shared.debug("Handling new data: \(data)")
        
        if let elapsedTime = try? JSONDecoder().decode(WorkoutElapsedTime.self, from: data) {
            Logger.shared.debug("Received elapsed time.")
            var currentElapsedTime: TimeInterval = 0
            if session?.state == .running {
                currentElapsedTime = elapsedTime.timeInterval + Date().timeIntervalSince(elapsedTime.date)
            } else {
                currentElapsedTime = elapsedTime.timeInterval
            }
            elapsedTimeInterval = currentElapsedTime
        } else if let statisticsArray = try NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClass: HKStatistics.self, from: data) {
            Logger.shared.debug("Received statistics.")
            for statistics in statisticsArray {
                updateForStatistics(statistics)
            }
        } else {
            Logger.shared.warning("Got data but cannot process: \(data)")
        }
    }
}
