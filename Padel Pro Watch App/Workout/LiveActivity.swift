//
//  LiveActivity.swift
//  Padel Pro Watch App
//
//  Created by Roland Kajatin on 22/10/2023.
//

import SwiftUI

struct LiveActivity: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        NavigationStack {
            TimelineView(LiveActivityTimelineSchedule(from: workoutManager.builder?.startDate ?? Date(), isPaused: workoutManager.session?.state == .paused)) { context in
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    ElapsedTimeView(elapsedTime: workoutManager.builder?.elapsedTime(at: context.date) ?? 0, showSubseconds: context.cadence == .live)
                        .foregroundStyle(Color.accentColor)
                    TotalEnergy(activeEnergy: workoutManager.activeEnergy)
                    HeartRate(heartRate: workoutManager.heartRate)
                }
            }
            .font(.system(.title).monospacedDigit().lowercaseSmallCaps())
            .fontWeight(.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .ignoresSafeArea(edges: .bottom)
            .scenePadding()
            .padding([.top], 25)
            //            .toolbar {
            //                ToolbarItem(placement: .topBarLeading) {
            //                    PadelIcon()
            //                }
            //            }
            .navigationTitle {
                Text(workoutManager.sessionState == .paused ? "Paused" : "")
                    .foregroundStyle(Color.accentColor)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct TotalEnergy: View {
    var activeEnergy: Double
    
    var body: some View {
        Text(
            Measurement(value: activeEnergy, unit: UnitEnergy.kilocalories)
                .formatted(
                    .measurement(width: .narrow, usage: .workout, numberFormatStyle: .number.precision(.fractionLength(0)))
                )
        )
    }
}

struct HeartRate: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var heartRate: Double
    
    var body: some View {
        HStack(alignment: .center) {
            Text(heartRate.formatted(.number.precision(.fractionLength(0))))
            PulsingHeart(heartRate: workoutManager.heartRate)
        }
    }
}

struct PadelIcon: View {
    @Namespace private var animation
    
    var body: some View {
        BubbleStack()
            .padding(2)
            .matchedGeometryEffect(id: "BubbleStack", in: animation)
    }
}

#Preview {
    let workoutManager = WorkoutManager.shared
    return LiveActivity().environmentObject(workoutManager)
}
