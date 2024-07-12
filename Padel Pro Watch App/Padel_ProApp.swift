//
//  Padel_ProApp.swift
//  Padel Pro Watch App
//
//  Created by Roland Kajatin on 22/10/2023.
//

import SwiftUI

@main
struct Padel_Pro_Watch_AppApp: App {
    private let workoutManager = WorkoutManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(SessionManager())
                .environmentObject(workoutManager)
                .onAppear {
                    workoutManager.requestAuthorization()
                }
        }
    }
}
