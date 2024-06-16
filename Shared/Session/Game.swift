//
//  Game.swift
//  Padel Pro Watch App
//
//  Created by Roland Kajatin on 16/06/2024.
//

import Foundation

enum GamePoint: String {
    case love = "0"
    case fifteen = "15"
    case thirty = "30"
    case forty = "40"
    case deuce = "D"
    case advantage = "A"
    case game = "G"

    func next() -> GamePoint {
        switch self {
        case .love:
            return .fifteen
        case .fifteen:
            return .thirty
        case .thirty:
            return .forty
        case .forty:
            return .game
        case .deuce:
            return .advantage
        case .advantage:
            return .game
        case .game:
            return .game
        }
    }
}

enum Team: Int {
    case away = 0
    case home = 1
}

struct Game {
    var points: (teamAway: GamePoint, teamHome: GamePoint)
    var isGoldenPoint: Bool

    init() {
        self.points = (GamePoint.love, GamePoint.love)
        self.isGoldenPoint = false
    }

    func winner() -> Team? {
        if points.teamAway == .game {
            return .away
        }
        if points.teamHome == .game {
            return .home
        }
        return nil
    }

    mutating func score(for team: Team) {
        // This game is already won.
        if points.teamAway == .game || points.teamHome == .game {
            return
        }

        // Back to deuce for any team.
        if points.teamAway == .advantage && team != .away {
            points.teamAway = .deuce
            return
        }
        if points.teamHome == .advantage && team != .home {
            points.teamHome = .deuce
            return
        }

        // Normal scoring logic.
        switch team {
        case .away:
            points.teamAway = GamePoint(rawValue: points.teamAway.rawValue)!.next()
        case .home:
            points.teamHome = GamePoint(rawValue: points.teamHome.rawValue)!.next()
        }

        // Enter deuce when needed.
        if points.teamAway == .forty && points.teamHome == .forty && !isGoldenPoint {
            points.teamAway = .deuce
            points.teamHome = .deuce
        }
    }
}
