//
//  Controls.swift
//  Padel Pro Watch App
//
//  Created by Roland Kajatin on 22/10/2023.
//

import SwiftUI
import UIKit

struct Controls: View {
    @State private var showEndSheet = false

    @Environment(SessionManager.self) var sessionManager
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
                        .monospaced()
                }

                VStack {
                    Button {
                        workoutManager.sessionState == .running ? workoutManager.session?.pause() : workoutManager.session?.resume()
                    } label: {
                        Image(systemName: workoutManager.sessionState == .running ? "pause" : "arrow.clockwise")
                    }
                    .tint(.offGray)
                    .font(.title2)

                    Text(workoutManager.sessionState == .running ? "Pause" : "Resume")
                        .monospaced()
                }
            }
            .sheet(isPresented: $showEndSheet) {
                VStack {
                    Text("Are you sure?")
                        .monospaced()
                    Button(role: .destructive) {
                        sessionManager.reset()
                        workoutManager.session?.stopActivity(with: .now)
                        showEndSheet = false
                    } label: {
                        Text("End Workout")
                            .monospaced()
                    }
                }
                .foregroundStyle(.offWhite)
            }
            .scenePadding()
            .foregroundStyle(.offWhite)
            .containerBackground(.offBlack, for: .navigation)
            .navigationTitle {
                Text(workoutManager.sessionState == .paused ? "Paused" : "Padel")
                    .foregroundStyle(.offWhite)
                    .monospaced()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    let workoutManager = WorkoutManager.shared
    return Controls()
        .environment(SessionManager())
        .environmentObject(workoutManager)
}
