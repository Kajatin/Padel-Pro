//
//  SessionManager.swift
//  Padel Watch App
//
//  Created by Roland Kajatin on 08/10/2023.
//

import OSLog
import Foundation

class SessionManager: ObservableObject {
    @Published private(set) var sessionData: SessionData = SessionData()

    // MARK: Intents

    func createTeams() {
        let player1 = Player(name: "Anonymous")
        let player2 = Player(name: "Anonymous")
        let player3 = Player(name: "Anonymous")
        let player4 = Player(name: "Anonymous")

        Logger.shared.debug("Creating default teams")
        createTeams(player1: player1, player2: player2, player3: player3, player4: player4)
    }

    func createTeams(player1: Player, player2: Player, player3: Player, player4: Player) {
        var teamA = Team(designation: .A)
        teamA.addPlayer(player1)
        teamA.addPlayer(player2)
        Logger.shared.debug("Created team A: \(String(describing: teamA))")

        var teamB = Team(designation: .B)
        teamB.addPlayer(player3)
        teamB.addPlayer(player4)
        Logger.shared.debug("Created team B: \(String(describing: teamB))")

        registerTeam(teamA)
        registerTeam(teamB)
    }

    func registerTeam(_ team: Team) {
        Logger.shared.debug("Registering team: \(String(describing: team))")
        sessionData.registerTeam(team)
    }

    func scoreTeam(designation: TeamDesignation) {
        Logger.shared.debug("Scoring for team: \(String(describing: designation))")
        sessionData.scoreTeam(designation: designation)
    }

    func reset() {
        Logger.shared.debug("Resetting session data")
        sessionData.reset()
    }
}
