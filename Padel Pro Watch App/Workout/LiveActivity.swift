//
//  LiveActivity.swift
//  Padel Pro Watch App
//
//  Created by Roland Kajatin on 22/10/2023.
//

import SwiftUI
import WatchKit

struct LiveActivity: View {
    @EnvironmentObject var workoutManager: WorkoutManager

    var body: some View {
        NavigationStack {
            TimelineView(LiveActivityTimelineSchedule(from: workoutManager.builder?.startDate ?? Date(), isPaused: workoutManager.session?.state == .paused)) { context in
                VStack {
                    Scores()
                    Spacer()
                    Timer(elapsedTime: workoutManager.builder?.elapsedTime(at: context.date) ?? 0, showSubseconds: context.cadence == .live)
                    Spacer()
                    Stats()
                }
                .scenePadding(.horizontal)
            }
            .foregroundStyle(.offWhite)
            .containerBackground(.offBlack, for: .navigation)
        }
    }

    struct Scores: View {
        let scoreSize: CGFloat = WKInterfaceDevice.current().screenBounds.width < 190 ? 18 : 20
        let winSize: CGFloat = WKInterfaceDevice.current().screenBounds.width < 190 ? 14 : 16
        
        @State private var rotationValue: Double = 0

        @Environment(SessionManager.self) var sessionManager

        var body: some View {
            if let winner = sessionManager.match.winner() {
                ZStack {
                    HStack {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Image(systemName: "crown")
                            Text(winner == .away ? "Opponent Won" : "You Won")
                        }
                        .font(.system(size: winSize, weight: .black, design: .monospaced))
                        
                        Spacer()
                    }
                    .offset(x: -abs(rotationValue / 4))
                    
                    Text("New Game")
                        .font(.system(size: winSize, weight: .black, design: .monospaced))
                        .offset(x: 140 - abs(rotationValue / 4))
                }
                .focusable(true)
                .digitalCrownRotation($rotationValue, from: -385, through: 385, sensitivity: .high, isContinuous: true, onChange: { event in
                    if abs(event.offset) >= (0.9 * 385) {
                        withAnimation {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                sessionManager.reset()
                            }
                        }
                    }
                })
            } else {
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 1) {
                        let scores = sessionManager.match.currentSet().scores()
                        HStack(spacing: 1) {
                            let score = scores.teamAway
                            let setsToWin = sessionManager.match.currentSet().setType == .regular ? 6 : 4
                            let scoreMissing = setsToWin - score
                            ForEach(0..<score, id: \.self) { _ in
                                Circle()
                                    .frame(width: 8)
                                    .foregroundStyle(.offWhite)
                            }
                            ForEach(0..<scoreMissing, id: \.self) { _ in
                                Circle()
                                    .frame(width: 8)
                                    .foregroundStyle(.offGray)
                            }
                        }
                        
                        HStack(spacing: 1) {
                            let score = scores.teamHome
                            let setsToWin = sessionManager.match.currentSet().setType == .regular ? 6 : 4
                            let scoreMissing = setsToWin - score
                            ForEach(0..<score, id: \.self) { _ in
                                Circle()
                                    .frame(width: 8)
                                    .foregroundStyle(.offWhite)
                            }
                            ForEach(0..<scoreMissing, id: \.self) { _ in
                                Circle()
                                    .frame(width: 8)
                                    .foregroundStyle(.offGray)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    ScorePill()
                }
            }
        }
    }

    private struct Timer: View {
        let timerSize: CGFloat = WKInterfaceDevice.current().screenBounds.width < 190 ? 28 : 32

        var elapsedTime: TimeInterval = 0
        var showSubseconds = true

        var body: some View {
            VStack(alignment: .center, spacing: 4) {
                ElapsedTimeView(elapsedTime: elapsedTime, showSubseconds: showSubseconds)
                    .font(.system(size: timerSize, weight: .black, design: .monospaced))

                HStack {
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 35, height: 3)
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 10, height: 3)
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 5, height: 3)
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 3, height: 3)
                    Spacer()
                }
            }
        }
    }

    struct Stats: View {
        let fontSize: CGFloat = WKInterfaceDevice.current().screenBounds.width < 190 ? 20 : 22

        @EnvironmentObject var workoutManager: WorkoutManager

        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(
                        Measurement(value: workoutManager.activeEnergy, unit: UnitEnergy.kilocalories)
                            .formatted(
                                .measurement(width: .narrow, usage: .workout, numberFormatStyle: .number.precision(.fractionLength(0)))
                            )
                    )
                        .font(.system(size: fontSize, weight: .bold, design: .monospaced))

                    HStack(alignment: .center) {
                        Text(workoutManager.heartRate.formatted(.number.precision(.fractionLength(0))))
                        PulsingHeart(heartRate: workoutManager.heartRate)
                    }
                        .font(.system(size: fontSize, weight: .bold, design: .monospaced))
                }

                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    let workoutManager = WorkoutManager.shared
    return LiveActivity()
        .environment(SessionManager())
        .environmentObject(workoutManager)
}
