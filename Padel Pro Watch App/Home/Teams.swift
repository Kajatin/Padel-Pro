//
//  Teams.swift
//  Padel Pro Watch App
//
//  Created by Roland Kajatin on 22/10/2023.
//

import SwiftUI

struct Teams: View {
    @State var player1 = Player()
    @State var player2 = Player()
    @State var player3 = Player()
    @State var player4 = Player()
    @State private var locationOptions: [WorkoutManager.Location] = [.indoors, .outdoors]
    
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        NavigationStack {
            Form {
                Section() {
                    Picker("Location", selection: $workoutManager.indoors) {
                        ForEach(locationOptions, id: \.self) { value in
                            switch value {
                            case .indoors:
                                Text("Indoors")
                            case .outdoors:
                                Text("Outdoors")
                            }
                        }
                    }
                }
                Section(header: Text("Team A")) {
                    TextField("Player 1", text: $player1.name)
                    TextField("Player 2", text: $player2.name)
                }
                Section(header: Text("Team B")) {
                    TextField("Player 1", text: $player3.name)
                    TextField("Player 2", text: $player4.name)
                }
                Button {
                    sessionManager.createTeams(player1: player1, player2: player2, player3: player3, player4: player4)
                } label: {
                    Text("Create")
                }
                if sessionManager.sessionData.teams.count > 0 {
                    Button("Reset", role: .destructive) {
                        sessionManager.reset()
                        workoutManager.reset()
                    }
                }
            }
            .navigationTitle {
                Text("Configuration")
                    .foregroundStyle(Color.accentColor)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    let sessionManager = SessionManager()
    let workoutManager = WorkoutManager.shared
    return Teams()
        .environmentObject(sessionManager)
        .environmentObject(workoutManager)
}
