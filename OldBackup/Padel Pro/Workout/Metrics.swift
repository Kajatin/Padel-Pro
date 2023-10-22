//
//  Metrics.swift
//  Padel Pro
//
//  Created by Roland Kajatin on 21/10/2023.
//

import SwiftUI

struct Metrics: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        TimelineView(LiveActivityTimelineSchedule(from: workoutManager.session?.startDate ?? Date(), isPaused: workoutManager.session?.state == .paused)) { context in
            VStack(alignment: .center) {
                ElapsedTimeView(elapsedTime: workoutTimeInterval(context.date), showSubseconds: context.cadence == .live)
                    .foregroundStyle(Color.accentColor)
                    .font(.system(size: 42))
                    .monospacedDigit()
                    .padding(.vertical)
                
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2), spacing: 0) {
                    TotalEnergy(activeEnergy: workoutManager.activeEnergy)
                        .padding(.horizontal, 4)
                    HeartRate(heartRate: workoutManager.heartRate)
                        .padding(.horizontal, 4)
                }
            }
        }
        .font(.system(.title).monospacedDigit().lowercaseSmallCaps())
        .fontWeight(.medium)
        .scenePadding(.horizontal)
        .padding(.bottom, 50)
        .background(Color.background)
    }
    
    private func workoutTimeInterval(_ contextDate: Date) -> TimeInterval {
        var timeInterval = workoutManager.elapsedTimeInterval
        if workoutManager.sessionState == .running {
            if let referenceContextDate = workoutManager.contextDate {
                timeInterval += (contextDate.timeIntervalSinceReferenceDate - referenceContextDate.timeIntervalSinceReferenceDate)
            } else {
                workoutManager.contextDate = contextDate
            }
        } else {
            var date = contextDate
            date.addTimeInterval(workoutManager.elapsedTimeInterval)
            timeInterval = date.timeIntervalSinceReferenceDate - contextDate.timeIntervalSinceReferenceDate
            workoutManager.contextDate = nil
        }
        return timeInterval
    }
}

struct TotalEnergy: View {
    var activeEnergy: Double
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(
                Measurement(value: activeEnergy, unit: UnitEnergy.kilocalories)
                    .formatted(
                        .measurement(width: .narrow, usage: .workout, numberFormatStyle: .number.precision(.fractionLength(0)))
                    )
            )
            .font(.system(size: 34))
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 40, alignment: .leading)
            
            Text("Active Kilocalories")
                .textCase(.uppercase)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
//                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 20, alignment: .leading)
        }
    }
}

struct HeartRate: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var heartRate: Double
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text(heartRate.formatted(.number.precision(.fractionLength(0))))
                PulsingHeart(heartRate: workoutManager.heartRate)
            }
            .font(.system(size: 34))
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 40, alignment: .leading)
            
            Text("Heart Rate")
                .textCase(.uppercase)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
//                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 20, alignment: .leading)
        }
    }
}


#Preview {
    let workoutManager = WorkoutManager.shared
    return Metrics()
        .environmentObject(workoutManager)
}
