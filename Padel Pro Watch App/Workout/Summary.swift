//
//  Summary.swift
//  Padel Pro Watch App
//
//  Created by Roland Kajatin on 22/10/2023.
//

import SwiftUI
import HealthKit

struct Summary: View {
    @Environment(SessionManager.self) var sessionManager
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        NavigationStack {
            Group {
                if let workout = workoutManager.workout {
                    ScrollView {
                        summaryListView(workout: workout)
                    }
                    .navigationTitle {
                        Text("Summary")
                            .foregroundStyle(Color.accentColor)
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    
                } else {
                    ProgressView()
                        .navigationBarHidden(true)
                }
            }
        }
    }
    
    @ViewBuilder
    private func summaryListView(workout: HKWorkout) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            SummaryMetricView(
                title: "Total Time",
                value: workout.totalTime,
                color: .yellow)
            Divider()
            
            SummaryMetricView(
                title: "Active Kilocalories",
                value: workout.totalEnergy,
                color: .pink)
            Divider()
            
            SummaryMetricView(
                title: "Average HR",
                value: workout.averageHeartRate,
                color: .red)
            HeartRateRange()
            Divider()
            
            TimeRange()
            //            Divider()
            //
            //            Rings()
        }
    }
}

struct SummaryMetricView: View {
    var title: String
    var value: String
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading  ) {
            Text(title)
                .textCase(.uppercase)
                .font(.system(size: 14))
            Text(value)
                .font(.system(size: 24).lowercaseSmallCaps())
                .fontWeight(.medium)
                .foregroundStyle(color)
        }
        .scenePadding(.horizontal)
        .padding(.vertical, 6)
    }
}

struct HeartRateRange: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        let rangeLow = (workoutManager.workout?.statistics(for: .init(HKQuantityTypeIdentifier.heartRate))?.minimumQuantity()?.doubleValue(for: .count().unitDivided(by: .minute())) ?? 0)
            .formatted(.number.precision(.fractionLength(0)))
        let rangeHigh = (workoutManager.workout?.statistics(for: .init(HKQuantityTypeIdentifier.heartRate))?.maximumQuantity()?.doubleValue(for: .count().unitDivided(by: .minute())) ?? 0)
            .formatted(.number.precision(.fractionLength(0)))
        
        VStack(alignment: .leading  ) {
            Text("Range")
                .textCase(.uppercase)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            Text("\(rangeLow)-\(rangeHigh) bpm")
                .font(.system(size: 14).lowercaseSmallCaps())
                .foregroundStyle(.red)
        }
        .scenePadding(.horizontal)
        .padding(.top, -4)
        .padding(.bottom, 6)
    }
}

struct TimeRange: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
    let date = Date.now
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(workoutManager.workout?.startDate.formatted(date: .long, time: .omitted) ?? "")")
            Text("\(workoutManager.workout?.startDate.formatted(date: .omitted, time: .shortened) ?? "") - \(workoutManager.workout?.endDate.formatted(date: .omitted, time: .shortened) ?? "")")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .scenePadding(.horizontal)
        .padding(.vertical, 6)
    }
}

struct Rings: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        VStack(alignment: .leading  ) {
            Text("Activity Rings")
                .textCase(.uppercase)
                .font(.system(size: 14))
            ActivityRings(healthStore: workoutManager.healthStore)
                .frame(width: 50, height: 50)
        }
        .scenePadding(.horizontal)
        .padding(.vertical, 6)
    }
}

#Preview {
    let workoutManager = WorkoutManager.shared
    return Summary()
        .environment(SessionManager())
        .environmentObject(workoutManager)
}
