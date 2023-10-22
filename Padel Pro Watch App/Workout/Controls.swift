//
//  Controls.swift
//  Padel Pro Watch App
//
//  Created by Roland Kajatin on 22/10/2023.
//

import SwiftUI

struct Controls: View {
    @State private var showEndSheet = false
    
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        NavigationStack {
            HStack {
                VStack {
                    Button {
                        showEndSheet = true
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(.red)
                    .font(.title2)
                    Text("End")
                }
                
                VStack {
                    Button {
                        workoutManager.sessionState == .running ? workoutManager.session?.pause() : workoutManager.session?.resume()
                    } label: {
                        Image(systemName: workoutManager.sessionState == .running ? "pause" : "arrow.clockwise")
                    }
                    .tint(.yellow)
                    .font(.title2)
                    
                    Text(workoutManager.sessionState == .running ? "Pause" : "Resume")
                }
            }
            .sheet(isPresented: $showEndSheet) {
                VStack {
                    Text("Are you sure?")
                    Button("End Workout", role: .destructive) {
                        sessionManager.reset()
                        workoutManager.session?.stopActivity(with: .now)
                        showEndSheet = false
                    }
                }
            }
            .navigationTitle {
                Text(workoutManager.sessionState == .paused ? "Paused" : "Padel")
                    .foregroundStyle(Color.accentColor)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    let sessionManager = SessionManager()
    let workoutManager = WorkoutManager.shared
    return Controls()
        .environmentObject(sessionManager)
        .environmentObject(workoutManager)
}
