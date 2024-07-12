//
//  PadelSet.swift
//  Padel Pro Watch App
//
//  Created by Roland Kajatin on 16/06/2024.
//

import OSLog
import Foundation

enum TieBreakerScore: Int, CaseIterable, Identifiable {
    case seven = 7
    case ten = 10
    
    var id: Self {
        return self
    }
    
    static func readFromUserDefaults() -> TieBreakerScore? {
        let rawValue = UserDefaults.standard.integer(forKey: "TieBreakerScore")

        return rawValue == 0 ? nil : TieBreakerScore(rawValue: rawValue)
    }
    
    func saveToUserDefaults() {
        UserDefaults.standard.set(self.rawValue, forKey: "TieBreakerScore")
    }
}

struct TieBreaker {
    var winningScore: Int
    var points: (teamAway: Int, teamHome: Int)
    
    init() {
        self.winningScore = TieBreakerScore.readFromUserDefaults()?.rawValue ?? 7
        self.points = (0, 0)
    }
    
    func winner() -> Team? {
        if points.teamAway >= winningScore && points.teamAway - points.teamHome >= 2 {
            return .away
        }
        if points.teamHome >= winningScore && points.teamHome - points.teamAway >= 2 {
            return .home
        }
        return nil
    }
    
    mutating func score(for team: Team) {
        switch team {
        case .away:
            points.teamAway += 1
        case .home:
            points.teamHome += 1
        }
    }
}

enum PadelSetType: String, CaseIterable, Identifiable {
    case regular
    case mini
    
    var id: Self {
        return self
    }

    static func readFromUserDefaults() -> PadelSetType? {
        if let rawValue = UserDefaults.standard.string(forKey: "PadelSetType") {
            return PadelSetType(rawValue: rawValue)
        }
        return nil
    }

    func saveToUserDefaults() {
        UserDefaults.standard.set(self.rawValue, forKey: "PadelSetType")
    }
}

struct PadelSet {
    var games: [Game]
    var setType: PadelSetType
    var tieBreaker: TieBreaker?
    
    init(tieBreaker: TieBreaker?) {
        self.games = [Game()]
        self.setType = PadelSetType.readFromUserDefaults() ?? .regular
        self.tieBreaker = tieBreaker
    }
    
    func currentGame() -> Game {
        return games.last!
    }
    
    func scores() -> (teamAway: Int, teamHome: Int) {
        var scoreAway = games.reduce(0, { score, game in
            return score + (game.winner() == .away ? 1 : 0)
        })
        var scoreHome = games.reduce(0, { score, game in
            return score + (game.winner() == .home ? 1 : 0)
        })
        if let tieBreaker = self.tieBreaker, let winningTeam = tieBreaker.winner() {
            if winningTeam == .away {
                scoreAway += 1
            } else {
                scoreHome += 1
            }
        }
        return (scoreAway, scoreHome)
    }

    func gamesToWin() -> Int {
        let base = setType == .mini ? 4 : 6
        
        if games.count != (2 * base) && tieBreaker != nil {
            return 1
        }
        
        let scores = self.scores()
        if scores.teamAway >= base - 1 && scores.teamHome >= base - 1 {
            return base + 1
        }
        
        return base
    }
    
    func winner() -> Team? {
        let (scoreAway, scoreHome) = scores()
        
        let winningScore = setType == .mini ? 4 : 6
        
        if (scoreAway >= winningScore || scoreHome >= winningScore) && abs(scoreAway - scoreHome) >= 2 {
            return scoreAway > scoreHome ? .away : .home
        }
        
        if let tieBreaker = tieBreaker {
            return tieBreaker.winner()
        }
        
        return nil
    }
    
    mutating func score(for team: Team) {
        if tieBreaker != nil {
            self.tieBreaker!.score(for: team)
            return
        } else {
            games[games.count - 1].score(for: team)
        }
        
        if winner() != nil {
            return
        }
        
        let (scoreAway, scoreHome) = scores()
        
        let winningScore = setType == .mini ? 4 : 6
        
        if scoreAway == winningScore && scoreHome == winningScore {
            tieBreaker = TieBreaker()
            return
        }
        
        if games[games.count - 1].winner() != nil {
            games.append(Game())
        }
    }
}
