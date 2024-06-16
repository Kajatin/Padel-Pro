//
//  ContentView.swift
//  Padel Pro Watch App
//
//  Created by Roland Kajatin on 22/10/2023.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        if workoutManager.sessionState.isActive || workoutManager.workout != nil {
            WorkoutTabView()
        } else {
            Home()
        }
    }
}

#Preview {
    let workoutManager = WorkoutManager.shared
    return ContentView()
        .environment(SessionManager())
        .environmentObject(workoutManager)
}
