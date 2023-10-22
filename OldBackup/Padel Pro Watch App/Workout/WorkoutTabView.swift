//
//  WorkoutTabView.swift
//  Padel Watch App
//
//  Created by Roland Kajatin on 08/10/2023.
//

import SwiftUI

struct WorkoutTabView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    
    @State private var isSheetActive = false
    @State private var selectedTab: WorkoutAppScreen? = .activity

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(WorkoutAppScreen.allCases) { screen in
                screen.destination
                    .tag(screen as WorkoutAppScreen?)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: isLuminanceReduced ? .never : .automatic))
        .onChange(of: workoutManager.sessionState) { _, newValue in
            if newValue == .ended || newValue == .stopped {
                isSheetActive = true
            } else if newValue == .running || newValue == .paused {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    displayLiveActivity()
                }
            }
        }
        .sheet(isPresented: $isSheetActive) {
            workoutManager.reset()
        } content: {
            Summary()
        }
    }
    
    private func displayLiveActivity() {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedTab = .activity
        }
    }
}

enum WorkoutAppScreen: Codable, Hashable, Identifiable, CaseIterable {
    case controls
    case activity
    case score

    var id: WorkoutAppScreen { self }
}

extension WorkoutAppScreen {
    @ViewBuilder
    var destination: some View {
        switch self {
        case .controls:
            Controls()
        case .activity:
            LiveActivity()
        case .score:
            LiveScore()
        }
    }
}

#Preview {
    let sessionManager = SessionManager()
    let workoutManager = WorkoutManager.shared
    return WorkoutTabView()
        .environmentObject(sessionManager)
        .environmentObject(workoutManager)
}
