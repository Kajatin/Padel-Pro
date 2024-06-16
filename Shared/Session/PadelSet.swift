//
//  PadelSet.swift
//  Padel Pro Watch App
//
//  Created by Roland Kajatin on 16/06/2024.
//

import OSLog
import Foundation

struct TieBreaker {
    var winningScore: Int
    var points: (teamAway: Int, teamHome: Int)
    
    init() {
        // TODO: read from userdefaults
        self.winningScore = 7
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

enum PadelSetType {
    case regular
    case mini
}

struct PadelSet {
    var games: [Game]
    var setType: PadelSetType
    var tieBreaker: TieBreaker?
    
    init(tieBreaker: TieBreaker?) {
        self.games = [Game()]
        // TODO: read from userdefaults
        self.setType = .regular
        self.tieBreaker = tieBreaker
    }
    
    func currentGame() -> Game {
        return games.last!
    }
    
    func scores() -> (teamAway: Int, teamHome: Int) {
        let scoreAway = games.reduce(0, { score, game in
            return score + (game.winner() == .away ? 1 : 0)
        })
        let scoreHome = games.reduce(0, { score, game in
            return score + (game.winner() == .home ? 1 : 0)
        })
        return (scoreAway, scoreHome)
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
