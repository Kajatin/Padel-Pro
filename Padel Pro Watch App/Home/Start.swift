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
    @State var showNoTeamsWarning = false
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                Button {
                    if sessionManager.sessionData.teams.count == 0 {
                        showNoTeamsWarning = true
                    } else {
                        startWorkout()
                    }
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
                
                HStack(alignment: .center) {
                    Text("Configure teams")
                    Image(systemName: "arrow.turn.right.down")
                }
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .if(sessionManager.sessionData.teams.count != 0) { view in
                    view.opacity(0)
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .sheet(isPresented: $showNoTeamsWarning) {
                VStack {
                    Text("No teams configured. Continue with defaults?")
                    Button {
                        sessionManager.createTeams()
                        startWorkout()
                        showNoTeamsWarning = false
                    } label: {
                        Text("Continue")
                    }
                }
            }
        }
    }
    
    private func startWorkout() {
        Task {
            do {
                let configuration = HKWorkoutConfiguration()
                configuration.activityType = .tennis
                configuration.locationType = workoutManager.indoors == .indoors ? .indoor : .outdoor
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
