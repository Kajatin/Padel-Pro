//
//  Match.swift
//  Padel Pro Watch App
//
//  Created by Roland Kajatin on 16/06/2024.
//

/* GAME DESCRIPTION
 - best of 3 sets
 - first to win 6 games with a lead of 2 wins a set
 - in case of a tie at 5-5 games, 2 more games are played to reach 7-5
 - in case of a tie at 6-6 games, a tie-breaker is played
 - tie breaker: first to 7 points with a difference of at least 2 points
 - serves: 1 / 2 / 2 .... alternating
 - a game is scored: 15, 30, 40, game
 - in case of a tie at 40 is called deuce
 - next point is advantage
 - must win by 2 points
 
 - alternative game score: golden point
 - love, 15, 30, 40, game
 - in case of a tie at 40 a single last point is played
 - the receiving pair decides which side receives the serve
 
 - alternative sets:
 - mini set: 4 games (win by at least 2)
 - 1-1 set won: immediate tie-break (7 points)
 - 1-1 set won: immediate tie-break (10 points)
 
 - serving:
 - flip of a coin
 - winner picks:
 - serving/receiving first - other team picks side
 - pick side - other team serving/receiving first
 - allow the other team to decide
 
 - change sides every odd number of games in a set
 - change side after every 6 points in a tie-break
 */

import Foundation

enum MatchType: String, CaseIterable, Identifiable {
    case regular
    case tieBreak
    
    var id: Self {
        return self
    }
    
    static func readFromUserDefaults() -> MatchType? {
        if let rawValue = UserDefaults.standard.string(forKey: "MatchType") {
            return MatchType(rawValue: rawValue)
        }
        return nil
    }
    
    func saveToUserDefaults() {
        UserDefaults.standard.set(self.rawValue, forKey: "MatchType")
    }
}

struct Match {
    var sets: [PadelSet]
    var matchType: MatchType
    
    init() {
        self.sets = [PadelSet(tieBreaker: nil)]
        self.matchType = MatchType.readFromUserDefaults() ?? .regular
    }
    
    func currentSet() -> PadelSet {
        return sets.last!
    }

    func scores() -> (teamAway: Int, teamHome: Int) {
        let scoreAway = sets.reduce(0, { score, set in
            return score + (set.winner() == .away ? 1 : 0)
        })
        let scoreHome = sets.reduce(0, { score, set in
            return score + (set.winner() == .home ? 1 : 0)
        })
        return (scoreAway, scoreHome)
    }
    
    func winner() -> Team? {
        let scoreAway = sets.reduce(0, { score, set in
            return score + (set.winner() == .away ? 1 : 0)
        })
        let scoreHome = sets.reduce(0, { score, set in
            return score + (set.winner() == .home ? 1 : 0)
        })
        
        if scoreAway >= 2 || scoreHome >= 2 {
            return scoreAway > scoreHome ? .away : .home
        }
        
        return nil
    }
    
    mutating func score(for team: Team) {
        sets[sets.count - 1].score(for: team)
        
        if winner() != nil {
            return
        }
        
        let scoreAway = sets.reduce(0, { score, set in
            return score + (set.winner() == .away ? 1 : 0)
        })
        let scoreHome = sets.reduce(0, { score, set in
            return score + (set.winner() == .home ? 1 : 0)
        })
        
        if sets[sets.count - 1].winner() != nil {
            let tieBreaker = (matchType == .tieBreak && scoreAway == 1 && scoreHome == 1) ? TieBreaker() : nil
            sets.append(PadelSet(tieBreaker: tieBreaker))
        }
    }
}
