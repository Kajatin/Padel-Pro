//
//  WorkoutManager.swift
//  Padel Watch App
//
//  Created by Roland Kajatin on 10/10/2023.
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
    @Published var elapsedTimeInterval: TimeInterval = 0
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

        // Send the elapsed time to the iOS side.
        let elapsedTimeInterval = session?.associatedWorkoutBuilder().elapsedTime(at: change.date) ?? 0
        let elapsedTime = WorkoutElapsedTime(timeInterval: elapsedTimeInterval, date: change.date)
        if let elapsedTimeData = try? JSONEncoder().encode(elapsedTime) {
            await sendData(elapsedTimeData)
        }

        guard change.newState == .stopped, let builder else {
            return
        }

        session?.end()

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
        }

        do {
            // Stop the mirrored session on iOS
            try await session?.stopMirroringToCompanionDevice()
            print("stopped mirroring")
        } catch {
            print("error stopping mirrored session: \(String(describing: error))")
            Logger.shared.error("Failed to stop mirroring to companion device: \(error)")
        }
#endif
    }
}

// MARK: - Workout Session Management

extension WorkoutManager {
    func reset() {
        Logger.shared.debug("Resetting workout state")

        self.indoors = .indoors
        self.sessionState = .notStarted

#if os(watchOS)
        self.builder = nil
#endif
        self.workout = nil
        self.session = nil

        self.heartRate = 0
        self.activeEnergy = 0
    }

    func sendData(_ data: Data) async {
//        Task {
            do {
                print("send before")
                try await session?.sendToRemoteWorkoutSession(data: data)
                print("send after")
            } catch {
                print("\(#function) Failed to send data: \(error)")
                Logger.shared.error("Failed to send data: \(error)")
            }
//        }
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
        print("changed state: \(fromState) to \(toState)")

        /// Yield the new state change to the async stream synchronously. `asynStreamTuple` is a constant, so it's nonisolated
        let sessionSateChange = SessionSateChange(newState: toState, date: date)
        asynStreamTuple.continuation.yield(sessionSateChange)
    }

    /// Tells the delegate that the session has failed with an error
    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession,
                                    didFailWithError error: Error) {
        Logger.shared.error("Session has failed with an error: \(String(describing: error))")
        print("failed with error")
    }

    /// Tells the delegate that the mirrored workout session is invalid
    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession,
                                    didDisconnectFromRemoteDeviceWithError error: Error?) {
//        reset()
        Logger.shared.error("Disconnected from remote device, error?: \(String(describing: error))")
        print("disconnect from remote")
    }

    /**
     In iOS, the sample app can go into the background and become suspended.
     When suspended, HealthKit gathers the data coming from the remote session.
     When the app resumes, HealthKit sends an array containing all the data objects it has accumulated to this delegate method.
     The data objects in the array appear in the order that the local system received them.

     On watchOS, the workout session keeps the app running even if it is in the background; however, the system can
     temporarily suspend the app — for example, if the app uses an excessive amount of CPU in the background.
     While suspended, HealthKit caches the incoming data objects and delivers an array of data objects when the app resumes, just like in the iOS app.
     */
    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession,
                                    didReceiveDataFromRemoteWorkoutSession data: [Data]) {
        print("receive data")
        Logger.shared.debug("Received data from remote workout session \(data.debugDescription)")
        Task { @MainActor in
            do {
                for anElement in data {
                    try handleReceivedData(anElement)
                }
            } catch {
                Logger.shared.log("Failed to handle received data: \(error)")
            }
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didGenerate event: HKWorkoutEvent) {
        print("did generate: \(event)")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didEndActivityWith workoutConfiguration: HKWorkoutConfiguration, date: Date) {
        print("did end")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didBeginActivityWith workoutConfiguration: HKWorkoutConfiguration, date: Date) {
        print("did begin")
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
