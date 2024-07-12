//
//  SessionManager.swift
//  Padel Pro Watch App
//
//  Created by Roland Kajatin on 22/10/2023.
//

import OSLog
import Foundation
import Observation

@Observable
class SessionManager {
    private(set) var match: Match = Match()
    
    // MARK: Intents
    
    func score(for team: Team) {
        Logger.shared.debug("Scoring for team: \(String(describing: team))")
        match.score(for: team)
    }
    
    func reset() {
        Logger.shared.debug("Resetting match.")
        match = Match()
    }
}
