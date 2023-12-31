//
//  Padel_ProApp.swift
//  Padel Pro Watch App
//
//  Created by Roland Kajatin on 22/10/2023.
//

import SwiftUI

@main
struct Padel_Pro_Watch_AppApp: App {
    private let sessionManager = SessionManager()
    private let workoutManager = WorkoutManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionManager)
                .environmentObject(workoutManager)
                .onAppear {
                    workoutManager.requestAuthorization()
                }
        }
    }
}
