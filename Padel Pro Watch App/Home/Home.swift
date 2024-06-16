//
//  Home.swift
//  Padel Pro Watch App
//
//  Created by Roland Kajatin on 22/10/2023.
//

import SwiftUI

struct Home: View {
    @State private var selectedTab: HomeAppScreen? = .start
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(HomeAppScreen.allCases) { screen in
                ZStack {
                    screen.destination
                        .tag(screen as HomeAppScreen?)
                }
            }
        }
        .tabViewStyle(.verticalPage)
    }
}

enum HomeAppScreen: Codable, Hashable, Identifiable, CaseIterable {
    case start
    
    var id: HomeAppScreen { self }
}

extension HomeAppScreen {
    @ViewBuilder
    var destination: some View {
        switch self {
        case .start:
            Start()
        }
    }
}

#Preview {
    let workoutManager = WorkoutManager.shared
    return Home()
        .environmentObject(workoutManager)
}
