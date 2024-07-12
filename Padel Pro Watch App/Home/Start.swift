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
    @Environment(SessionManager.self) var sessionManager
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        VStack(alignment: .center) {
            Button {
                startWorkout()
            } label: {
                ZStack {
                    BubbleStack()
                        .matchedGeometryEffect(id: "BubbleStack", in: animation)
                    Text("Start")
                        .font(.system(size: 26, weight: .black, design: .monospaced))
                        .fontWeight(.medium)
                        .foregroundStyle(Color.accentColor)
                }
            }
            .buttonStyle(.plain)
            .scenePadding()
        }
    }
    
    private func startWorkout() {
        Task {
            do {
                sessionManager.reset()
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
    let workoutManager = WorkoutManager.shared
    return Start()
        .environment(SessionManager())
        .environmentObject(workoutManager)
}
