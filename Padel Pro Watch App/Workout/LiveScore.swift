//
//  LiveScore.swift
//  Padel Pro Watch App
//
//  Created by Roland Kajatin on 22/10/2023.
//

import SwiftUI

struct LiveScore: View {
    @Environment(SessionManager.self) var sessionManager
    
    let fontSize: CGFloat = WKInterfaceDevice.current().screenBounds.width < 190 ? 14 : 16
    
    @State private var showResetSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                GameScore()
                
                Spacer()
                
                VStack {
                    ForEach(0..<sessionManager.match.sets.count, id: \.self) { index in
                        if index < sessionManager.match.sets.count {
                            HStack(alignment: .center) {
                                Text("Set \(index + 1)")
                                    .font(.system(size: fontSize, weight: .bold, design: .monospaced))
                                
                                if sessionManager.match.sets[index].tieBreaker != nil {
                                    Image(systemName: "rosette")
                                }
                                
                                Spacer()
                                
                                SetScore(scores: sessionManager.match.sets[index].scores(), gamesToWin: sessionManager.match.sets[index].gamesToWin())
                            }
                        }
                    }
                }
            }
            .scenePadding([.horizontal, .bottom])
            .foregroundStyle(.offWhite)
            .containerBackground(.offBlack, for: .navigation)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Badges()
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showResetSheet = true
                    } label: {
                        Image(systemName: "arrow.uturn.backward")
                    }
                }
            }
            .alert("Start a new match?", isPresented: $showResetSheet) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    sessionManager.reset()
                }
            }
        }
    }
}

struct SetScore: View {
    var scores: (teamAway: Int, teamHome: Int)
    var gamesToWin: Int
    
    let bubbleWH: CGFloat = WKInterfaceDevice.current().screenBounds.width < 190 ? 6 : 8
    
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 1) {
                let score = scores.teamAway
                let scoreMissing = gamesToWin - score
                ForEach(0..<score, id: \.self) { _ in
                    Circle()
                        .frame(width: bubbleWH)
                        .foregroundStyle(.offWhite)
                }
                ForEach(0..<scoreMissing, id: \.self) { _ in
                    Circle()
                        .frame(width: bubbleWH)
                        .foregroundStyle(.offGray)
                }
            }
            
            HStack(spacing: 1) {
                let score = scores.teamHome
                let scoreMissing = gamesToWin - score
                ForEach(0..<score, id: \.self) { _ in
                    Circle()
                        .frame(width: bubbleWH)
                        .foregroundStyle(.offWhite)
                }
                ForEach(0..<scoreMissing, id: \.self) { _ in
                    Circle()
                        .frame(width: bubbleWH)
                        .foregroundStyle(.offGray)
                }
            }
        }
        .frame(height: 2*bubbleWH)
    }
}

struct Badges: View {
    @Environment(SessionManager.self) var sessionManager
    
    var body: some View {
        HStack {
            Image(systemName: "tennisball.fill")
            
            if sessionManager.match.currentSet().tieBreaker != nil {
                Image(systemName: "rosette")
            }
            
            if sessionManager.match.matchType == .tieBreak {
                Image(systemName: "triangle.fill")
            }
            
            if sessionManager.match.currentSet().setType == .mini {
                Image(systemName: "bolt.circle.fill")
            }
        }
        .foregroundStyle(.offGray)
    }
}

struct GameScore: View {
    @Environment(SessionManager.self) var sessionManager
    
    let fontSize: CGFloat = WKInterfaceDevice.current().screenBounds.width < 190 ? 12 : 14
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 0) {
                Text("Away")
                Spacer()
                Text("Home")
            }
            .padding(.horizontal)
            .font(.system(size: fontSize, weight: .medium, design: .monospaced))
            .foregroundStyle(.offGray)
            
            ScorePill(winner: sessionManager.match.winner())
        }
    }
}

#Preview {
    LiveScore()
        .environment(SessionManager())
}
