//
//  WorkoutTabView.swift
//  Padel Pro Watch App
//
//  Created by Roland Kajatin on 22/10/2023.
//

import SwiftUI

struct WorkoutTabView: View {
    @Environment(SessionManager.self) var sessionManager
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    
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
            if newValue == .running || newValue == .paused {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    displayLiveActivity()
                }
            }
        }
        .sheet(isPresented: $workoutManager.showSummary) {
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
    let workoutManager = WorkoutManager.shared
    return WorkoutTabView()
        .environment(SessionManager())
        .environmentObject(workoutManager)
}
