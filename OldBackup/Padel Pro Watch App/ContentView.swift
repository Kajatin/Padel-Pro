//
//  ContentView.swift
//  Padel Watch App
//
//  Created by Roland Kajatin on 08/10/2023.
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
    let sessionManager = SessionManager()
    let workoutManager = WorkoutManager.shared
    return ContentView()
        .environmentObject(sessionManager)
        .environmentObject(workoutManager)
}
