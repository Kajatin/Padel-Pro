//
//  Start.swift
//  Padel Pro Watch App
//
//  Created by Roland Kajatin on 22/10/2023.
//

import OSLog
import SwiftUI
import HealthKit

struct Start: View {
    @Namespace private var animation
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                Button {
                    startWorkout()
                } label: {
                    ZStack {
                        BubbleStack()
                            .matchedGeometryEffect(id: "BubbleStack", in: animation)
                        Text("Start")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundStyle(Color.accentColor)
                    }
                }
                .buttonStyle(.plain)
                .scenePadding()
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
    
    private func startWorkout() {
        Task {
            do {
                sessionManager.createTeams()
                let configuration = HKWorkoutConfiguration()
                configuration.activityType = .tennis
                Logger.shared.debug("Creating session with configuration: \(String(describing: configuration))")
                try await workoutManager.startWorkout(workoutConfiguration: configuration)
            } catch {
                // TODO: UI for error case
                workoutManager.reset()
                Logger.shared.error("Failed to start workout \(error)")
            }
        }
    }
}

#Preview {
    let sessionManager = SessionManager()
    let workoutManager = WorkoutManager.shared
    return Start()
        .environmentObject(sessionManager)
        .environmentObject(workoutManager)
}
