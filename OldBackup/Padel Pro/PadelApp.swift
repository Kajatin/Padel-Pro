//
//  PadelApp.swift
//  Padel
//
//  Created by Roland Kajatin on 08/10/2023.
//

import SwiftUI

@main
struct PadelApp: App {
    private let sessionManager = SessionManager()
    private let workoutManager = WorkoutManager.shared
    
    var body: some Scene {
        WindowGroup {
            StartView()
                .environmentObject(sessionManager)
                .environmentObject(workoutManager)
        }
    }
}
