//
//  WorkoutManager.swift
//  Padel Pro Watch App
//
//  Created by Roland Kajatin on 22/10/2023.
//

import OSLog
import HealthKit
import Foundation

#if os(watchOS)
import WatchKit
#endif

// TODO: Add weather related information
// https://developer.apple.com/documentation/healthkit/hkworkoutbuilder/2962910-addmetadata
// https://developer.apple.com/documentation/healthkit/hkmetadatakeybarometricpressure

@MainActor
class WorkoutManager: NSObject, ObservableObject {
    struct SessionSateChange {
        let newState: HKWorkoutSessionState
        let date: Date
    }
    
    /// Workout session live states that the UI observes
    @Published var indoors: Location = .indoors
    @Published var sessionState: HKWorkoutSessionState = .notStarted
    @Published var heartRate: Double = 0
    @Published var activeEnergy: Double = 0
    @Published var showSummary = false
    /// Summary view (watchOS) displays the workout results at the end of the session
    @Published var workout: HKWorkout?
    
    /// The quantity types to share to the health store
    let typesToShare: Swift.Set = [
        HKQuantityType.workoutType()
    ]
    
    /// The quantity types to read from the health store
    let typesToRead: Swift.Set = [
        HKQuantityType(.heartRate),
        HKQuantityType(.activeEnergyBurned),
        HKObjectType.activitySummaryType(),
    ]
    
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
#if os(watchOS)
    /// The live workout builder that is only available on watchOS
    var builder: HKLiveWorkoutBuilder?
#else
    /// A date for synchronizing the elapsed time between iOS and watchOS
    var contextDate: Date?
#endif
    
    /**
     Creates an async stream that buffers a single newest element, and the stream's continuation to yield new elements synchronously to the stream.
     The Swift actors don't handle tasks in a first-in-first-out way. Use AsyncStream to make sure that the app presents the latest state.
     */
    let asynStreamTuple = AsyncStream.makeStream(of: SessionSateChange.self, bufferingPolicy: .bufferingNewest(1))
    
    /// WorkoutManager is a singleton
    static let shared = WorkoutManager()
    
    /**
     Kick off a task to consume the async stream. The next value in the stream can't start processing
     until "await consumeSessionStateChange(value)" returns and the loop enters the next iteration, which serializes the asynchronous operations.
     */
    private override init() {
        super.init()
        Task {
            for await value in asynStreamTuple.stream {
                await consumeSessionStateChange(value)
            }
        }
    }
    
    /// Consume the session state change from the async stream to update sessionState and finish the workout.
    private func consumeSessionStateChange(_ change: SessionSateChange) async {
        Logger.shared.debug("State changed: \(String(describing: change.newState))")
        sessionState = change.newState
        
#if os(watchOS)
        switch change.newState {
        case .paused:
            WKInterfaceDevice.current().play(.stop)
        case .running:
            WKInterfaceDevice.current().play(.start)
        default: break
        }
        
        let elapsedTimeInterval = session?.associatedWorkoutBuilder().elapsedTime(at: change.date) ?? 0
        
        guard change.newState == .stopped, let builder else {
            return
        }
        
        session?.end()
        
        if elapsedTimeInterval >= 60 {
            showSummary = true
        }
        
        do {
            try await builder.endCollection(at: change.date)
            
            // Discard workout if elapsed time is too short.
            if elapsedTimeInterval < 60 {
                Logger.shared.debug("Workout duration was less than 60 seconds, discarding")
                builder.discardWorkout()
                reset()
            } else {
                // Save the workout to the store.
                let finishedWorkout = try await builder.finishWorkout()
                workout = finishedWorkout
            }
        } catch {
            Logger.shared.error("Failed to end workout: \(error)")
            reset()
        }
#endif
    }
}

// MARK: - Workout Session Management

extension WorkoutManager {
    func reset() {
        Logger.shared.debug("Resetting workout state")
        
        indoors = .indoors
        sessionState = .notStarted
        showSummary = false
        
#if os(watchOS)
        builder = nil
#endif
        workout = nil
        session = nil
        
        heartRate = 0
        activeEnergy = 0
    }
}

// MARK: - Workout Metrics

extension WorkoutManager {
    func updateForStatistics(_ statistics: HKStatistics) {
        switch statistics.quantityType {
        case HKQuantityType.quantityType(forIdentifier: .heartRate):
            let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
            heartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
            
        case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
            let energyUnit = HKUnit.kilocalorie()
            activeEnergy = statistics.sumQuantity()?.doubleValue(for: energyUnit) ?? 0
            
        default:
            return
        }
    }
}

// MARK: - HKWorkoutSessionDelegate

// HealthKit calls the delegate methods on an anonymous serial background queue,
// so the methods need to be nonisolated explicitly.
extension WorkoutManager: HKWorkoutSessionDelegate {
    /// Tells the delegate that the session’s state has changed
    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession,
                                    didChangeTo toState: HKWorkoutSessionState,
                                    from fromState: HKWorkoutSessionState,
                                    date: Date) {
        Logger.shared.debug("Workout session has changed state from \(fromState.rawValue) to \(toState.rawValue)")
        
        /// Yield the new state change to the async stream synchronously. `asynStreamTuple` is a constant, so it's nonisolated
        let sessionSateChange = SessionSateChange(newState: toState, date: date)
        asynStreamTuple.continuation.yield(sessionSateChange)
    }
    
    /// Tells the delegate that the session has failed with an error
    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession,
                                    didFailWithError error: Error) {
        Logger.shared.error("Session has failed with an error: \(String(describing: error))")
    }
}

extension WorkoutManager {
    enum Location: CaseIterable, Identifiable {
        case indoors
        case outdoors
        
        var id: Location { self }
        
        var description: String {
            switch self {
            case .indoors:
                return "Indoors"
            case .outdoors:
                return "Outdoors"
            }
        }
    }
}

// MARK: - Convenient workout state

extension HKWorkoutSessionState {
    var isActive: Bool {
        self != .notStarted && self != .ended
    }
}

// MARK: - A structure for synchronizing the elapsed time

struct WorkoutElapsedTime: Codable {
    var timeInterval: TimeInterval
    var date: Date
}
