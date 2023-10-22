//
//  PadelApp.swift
//  Padel Watch App
//
//  Created by Roland Kajatin on 08/10/2023.
//

import SwiftUI

@main
struct Padel_Watch_AppApp: App {
    @WKApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    private let sessionManager = SessionManager()
    private let workoutManager = WorkoutManager.shared
    
    @SceneBuilder var body: some Scene {
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
