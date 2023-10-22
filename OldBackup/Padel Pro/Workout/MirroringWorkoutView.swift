//
//  MirroringWorkoutView.swift
//  Padel Pro
//
//  Created by Roland Kajatin on 15/10/2023.
//

import SwiftUI

struct MirroringWorkoutView: View {
    @State private var showEndSheet = false
    
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 0) {
                LiveScore()
                Metrics()
                Controls(showEndSheet: $showEndSheet)
            }
            .alert("Are you sure?", isPresented: $showEndSheet) {
                Button("End Workout", role: .destructive) {
//                    sessionManager.reset()
                    workoutManager.session?.stopActivity(with: .now)
                    showEndSheet = false
                }
            }
        }
    }
}

#Preview {
    let sessionManager = SessionManager()
    let workoutManager = WorkoutManager.shared
    return MirroringWorkoutView()
        .environmentObject(sessionManager)
        .environmentObject(workoutManager)
}
