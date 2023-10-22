//
//  SessionData.swift
//  Padel Pro Watch App
//
//  Created by Roland Kajatin on 22/10/2023.
//

import Foundation

struct SessionData {
    var teams: [Team] = []
    var sets: [Set] = [Set(id: 0)]
    var setWinners: [TeamDesignation] = []
    var winner: TeamDesignation?
    var serving: TeamDesignation = .A
    
    var teamA: Team? {
        get {
            return teams.first(where: { $0.designation == .A })
        }
    }
    
    var teamB: Team? {
        get {
            return teams.first(where: { $0.designation == .B })
        }
    }
    
    mutating func scoreTeam(designation: TeamDesignation) {
        if self.winner != nil {
            return
        }
        
        if let teamIndex = teams.firstIndex(where: { $0.designation == designation }) {
            self.teams[teamIndex].score.addPoint()
        }
        
        var resetRally = false
        var resetSet = false
        
        // Check if the rally is over
        if teamA!.score.point == .advantage {
            // Team A wins the rally
            self.sets[self.sets.count - 1].addPointForTeam(designation: .A)
            resetRally = true
        }
        
        if teamB!.score.point == .advantage {
            // Team B wins the rally
            self.sets[self.sets.count - 1].addPointForTeam(designation: .B)
            resetRally = true
        }
        
        // Check if the set is over
        if sets.last!.pointsForTeam(designation: .A) == 7 || (sets.last!.pointsForTeam(designation: .A) == 6 && sets.last!.pointsForTeam(designation: .B) <= 4) {
            // Team A wins the set
            resetSet = true
            self.setWinners.append(.A)
        }
        
        if sets.last!.pointsForTeam(designation: .B) == 7 || (sets.last!.pointsForTeam(designation: .B) == 6 && sets.last!.pointsForTeam(designation: .A) <= 4) {
            // Team B wins the set
            resetSet = true
            self.setWinners.append(.B)
        }
        
        // Check if the game is over
        if setWinners.filter({ $0 == .A }).count == 2 {
            // Team A wins the game
            self.winner = .A
            resetRally = false
            resetSet = false
        }
        
        if setWinners.filter({ $0 == .B }).count == 2 {
            // Team B wins the game
            self.winner = .B
            resetRally = false
            resetSet = false
        }
        
        if resetRally {
            self.teams[0].score.reset()
            self.teams[1].score.reset()
            self.serving = serving == .A ? .B : .A
        }
        
        if resetSet {
            self.sets.append(Set(id: sets.count))
        }
    }
    
    mutating func registerTeam(_ team: Team) {
        // There can only be one team with a given designation
        if teams.contains(where: { $0.designation == team.designation }) {
            return
        }
        
        self.teams.append(team)
    }
    
    mutating func reset(preserveTeams: Bool = false) {
        if (!preserveTeams) {
            self.teams = []
        } else {
            for i in 0..<teams.count {
                self.teams[i].score.reset()
            }
        }
        self.sets = [Set(id: 0)]
        self.setWinners = []
        self.winner = nil
        self.serving = .A
    }
}

enum TeamDesignation {
    case A
    case B
}

struct Team {
    var score: Score = Score()
    var players: [Player] = []
    var designation: TeamDesignation
    
    init(designation: TeamDesignation) {
        self.designation = designation
    }
    
    var slug: String {
        get {
            return players.map { $0.slug }.joined(separator: "/").uppercased()
        }
    }
    
    mutating func addPlayer(_ player: Player) {
        if players.count == 2 {
            return
        }
        players.append(player)
    }
}

struct Player {
    var name: String = ""
    var slug: String {
        String(name.prefix(1))
    }
}

struct Score {
    enum Points: Int {
        case zero = 0
        case fifteen = 15
        case thirty = 30
        case forty = 40
        case advantage = 45
    }
    
    var point: Points = .zero
    
    mutating func reset() {
        self.point = .zero
    }
    
    mutating func addPoint() {
        switch point {
        case .zero:
            point = .fifteen
        case .fifteen:
            point = .thirty
        case .thirty:
            point = .forty
        case .forty:
            point = .advantage
        default:
            break
        }
    }
}

struct Set: Identifiable {
    var id: Int
    var points: [TeamDesignation] = []
    
    func pointsForTeam(designation: TeamDesignation) -> Int {
        return points.filter { $0 == designation }.count
    }
    
    func teamLeadingIs(designation: TeamDesignation) -> Bool {
        return pointsForTeam(designation: designation) > pointsForTeam(designation: designation == .A ? .B : .A)
    }
    
    mutating func addPointForTeam(designation: TeamDesignation) {
        self.points.append(designation)
    }
}
