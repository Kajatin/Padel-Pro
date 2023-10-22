//
//  Controls.swift
//  Padel Watch App
//
//  Created by Roland Kajatin on 08/10/2023.
//

import SwiftUI

struct Controls: View {
    @State private var showEndSheet = false

    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var workoutManager: WorkoutManager

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Image(systemName: "xmark")
                        .font(.system(size: 28, weight: .light))
                }
                .background(
                    ZStack {
                        Circle()
                            .fill(Color.backgroundRed)
                            .frame(width: 60, height: 60)
                            .shadow(color: Color.lightShadowRed, radius: 4, x: -4, y: -4)
                            .shadow(color: Color.darkShadowRed, radius: 4, x: 4, y: 4)
                    }
                )
                .position(x: geometry.size.width * 0.25, y: geometry.frame(in: .local).midY)
                .onTapGesture (count: 1) {
                    showEndSheet.toggle()
                }
                
                ZStack {
                    Image(systemName: workoutManager.sessionState == .running ? "pause" : "arrow.clockwise")
                        .font(.system(size: 28, weight: .light))
                }
                .background(
                    ZStack {
                        Circle()
                            .fill(Color.background)
                            .frame(width: 60, height: 60)
                            .shadow(color: Color.lightShadow, radius: 4, x: -4, y: -4)
                            .shadow(color: Color.darkShadow, radius: 4, x: 4, y: 4)
                    }
                )
                .position(x: geometry.size.width * 0.75, y: geometry.frame(in: .local).midY)
                .onTapGesture(count: 1) {
                    workoutManager.sessionState == .running ? workoutManager.session?.pause() : workoutManager.session?.resume()
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
            .containerBackground(Color.background, for: .navigation)
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
