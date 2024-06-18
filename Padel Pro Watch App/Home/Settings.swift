//
//  Settings.swift
//  Padel Pro Watch App
//
//  Created by Roland Kajatin on 17/06/2024.
//

import SwiftUI

struct Settings: View {
    @State private var tieBreakerScore: TieBreakerScore = .readFromUserDefaults() ?? .seven
    @State private var padelSetType: PadelSetType = .readFromUserDefaults() ?? .regular
    @State private var matchType: MatchType = .readFromUserDefaults() ?? .regular
    
    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Set Configuration"), footer: Text("Set configuration is used to determine the winning score for a set and the type of set to be played.")) {
                    VStack {
                        Picker("Tie Breaker Score", selection: $tieBreakerScore) {
                            ForEach(TieBreakerScore.allCases) { score in
                                Text("\(score.rawValue)").tag(score)
                            }
                        }
                    }
                    
                    Picker("Padel Set Type", selection: $padelSetType) {
                        ForEach(PadelSetType.allCases) { type in
                            Text(type.rawValue.capitalized).tag(type)
                        }
                    }
                }
                
                Section(header: Text("Match Configuration"), footer: Text("In tie break mode, the third set is skipped and an immediate tie breaker is played instead.")) {
                    Picker("Match Type", selection: $matchType) {
                        ForEach(MatchType.allCases) { type in
                            switch type {
                            case .regular:
                                Text(type.rawValue.capitalized).tag(type)
                            case .tieBreak:
                                Text("Tie Break").tag(type)
                            }
                        }
                    }
                }
                
                Section {
                    Button("Reset to Defaults", role: .destructive) {
                        showResetConfirmation = true
                    }
                }
            }
            .alert("Reset to Defaults", isPresented: $showResetConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    tieBreakerScore = .seven
                    padelSetType = .regular
                    matchType = .regular
                }
            }
            .navigationTitle("Settings")
        }
        .onDisappear {
            tieBreakerScore.saveToUserDefaults()
            padelSetType.saveToUserDefaults()
            matchType.saveToUserDefaults()
        }
    }
}

#Preview {
    Settings()
}
