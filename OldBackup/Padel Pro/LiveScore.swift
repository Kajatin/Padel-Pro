//
//  LiveScore.swift
//  Padel Pro
//
//  Created by Roland Kajatin on 18/10/2023.
//

import SwiftUI

struct LiveScore: View {
    var body: some View {
        VStack {
            SetScore()
            RallyScore()
//            Rallies()
        }
        .foregroundStyle(.black)
        .background(Color.accentColor)
    }
}

struct RallyScore: View {
    private var emptyCell: some View = Color.clear
        .gridCellUnsizedAxes([.horizontal, .vertical])
    
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        HStack {
            VStack(spacing: 10) {
                ZStack {
                    Image(systemName: "tennisball.fill")
                        .if(sessionManager.sessionData.serving != .A || sessionManager.sessionData.winner != nil) { view in
                            view.opacity(0)
                        }

                    Image(systemName: "crown.fill")
                        .if(sessionManager.sessionData.winner != .A) { view in
                            view.opacity(0)
                        }
                }
                Text("\(sessionManager.sessionData.teamA?.score.point.rawValue ?? 0)")
                    .font(.system(size: 50))
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.top)
            
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 2)
                .padding()
            
            VStack(spacing: 10) {
                ZStack {
                    Image(systemName: "tennisball.fill")
                        .if(sessionManager.sessionData.serving != .B || sessionManager.sessionData.winner != nil) { view in
                            view.opacity(0)
                        }
                    
                    Image(systemName: "crown.fill")
                        .if(sessionManager.sessionData.winner != .B) { view in
                            view.opacity(0)
                        }
                }
                Text("\(sessionManager.sessionData.teamB?.score.point.rawValue ?? 0)")
                    .font(.system(size: 50))
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.top)
        }
        .padding([.horizontal, .bottom])
    }
}

struct SetScore: View {
    private var topBorder = UnevenRoundedRectangle(cornerRadii: .init(topLeading: 5, bottomLeading: 0, bottomTrailing: 0, topTrailing: 5), style: .continuous)
    private var bottomBorder = UnevenRoundedRectangle(cornerRadii: .init(topLeading: 0, bottomLeading: 5, bottomTrailing: 5, topTrailing: 0), style: .continuous)
    
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        Grid(alignment: .leadingFirstTextBaseline) {
            GridRow {
                Text(sessionManager.sessionData.teamA?.slug ?? "??/??")
                    .frame(minWidth: 35)
                    .padding([.horizontal], 3)
                    .overlay(topBorder.stroke(.secondary))
                    .if(sessionManager.sessionData.winner == .A) { view in
                        view
                            .background(.secondary)
                    }
                ForEach(sessionManager.sessionData.sets) { set in
                    Text("\(set.pointsForTeam(designation: .A))")
                        .frame(minWidth: 10)
                        .padding([.horizontal], 3)
                        .if(set.teamLeadingIs(designation: .A)) { view in
                            view
                                .background(.secondary)
                        }
                        .clipShape(topBorder)
                        .overlay(topBorder.stroke(.secondary))
                }
            }
            
            GridRow {
                Text(sessionManager.sessionData.teamB?.slug ?? "??/??")
                    .frame(minWidth: 35)
                    .padding([.horizontal], 3)
                    .overlay(bottomBorder.stroke(.secondary))
                    .if(sessionManager.sessionData.winner == .B) { view in
                        view
                            .background(.secondary)
                    }
                ForEach(sessionManager.sessionData.sets) { set in
                    Text("\(set.pointsForTeam(designation: .B))")
                        .frame(minWidth: 10)
                        .padding([.horizontal], 3)
                        .if(set.teamLeadingIs(designation: .B)) { view in
                            view
                                .background(.secondary)
                        }
                        .clipShape(bottomBorder)
                        .overlay(bottomBorder.stroke(.secondary))
                }
            }
        }
        .padding([.leading], 3)
    }
}

struct Rallies: View {
    private var topBorder = UnevenRoundedRectangle(cornerRadii: .init(topLeading: 5, bottomLeading: 0, bottomTrailing: 0, topTrailing: 5), style: .continuous)
    private var bottomBorder = UnevenRoundedRectangle(cornerRadii: .init(topLeading: 0, bottomLeading: 5, bottomTrailing: 5, topTrailing: 0), style: .continuous)
    
    var body: some View {
        ScrollView {
            HStack(spacing: 4) {
                VStack {
                    Text("15")
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 2)
                        .foregroundStyle(.tertiary)
                    Text("0")
                }
                
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 2)
                    .foregroundStyle(.tertiary)
                
                VStack {
                    Text("15")
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 2)
                        .foregroundStyle(.tertiary)
                    Text("15")
                }
                
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 2)
                    .foregroundStyle(.tertiary)
                
                VStack {
                    Text("15")
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 2)
                        .foregroundStyle(.tertiary)
                    Text("30")
                }
                
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 2)
                    .foregroundStyle(.tertiary)
                
                VStack {
                    Text("15")
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 2)
                        .foregroundStyle(.tertiary)
                    Text("40")
                }
            }
            .font(.system(size: 20))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.background, lineWidth: 2))
            .padding()
            
            HStack(spacing: 4) {
                VStack {
                    Text("15")
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 2)
                        .foregroundStyle(.tertiary)
                    Text("0")
                }
                
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 2)
                    .foregroundStyle(.tertiary)
                
                VStack {
                    Text("15")
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 2)
                        .foregroundStyle(.tertiary)
                    Text("15")
                }
                
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 2)
                    .foregroundStyle(.tertiary)
                
                VStack {
                    Text("15")
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 2)
                        .foregroundStyle(.tertiary)
                    Text("30")
                }
                
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 2)
                    .foregroundStyle(.tertiary)
                
                VStack {
                    Text("15")
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 2)
                        .foregroundStyle(.tertiary)
                    Text("40")
                }
            }
            .font(.system(size: 20))
            .padding(.horizontal)
            
            HStack(spacing: 4) {
                VStack {
                    Text("15")
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 2)
                        .foregroundStyle(.tertiary)
                    Text("0")
                }
                
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 2)
                    .foregroundStyle(.tertiary)
                
                VStack {
                    Text("15")
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 2)
                        .foregroundStyle(.tertiary)
                    Text("15")
                }
                
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 2)
                    .foregroundStyle(.tertiary)
                
                VStack {
                    Text("15")
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 2)
                        .foregroundStyle(.tertiary)
                    Text("30")
                }
                
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 2)
                    .foregroundStyle(.tertiary)
                
                VStack {
                    Text("15")
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 2)
                        .foregroundStyle(.tertiary)
                    Text("40")
                }
            }
            .font(.system(size: 20))
            .padding(.horizontal)
        }
    }
}

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview {
    let sessionManager = SessionManager()
    return LiveScore()
        .environmentObject(sessionManager)
}
