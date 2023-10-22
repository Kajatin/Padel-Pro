//
//  LiveScore.swift
//  Padel Watch App
//
//  Created by Roland Kajatin on 08/10/2023.
//

import SwiftUI

struct LiveScore: View {
    @State private var homeScore: Int = 0
    @State private var awayScore: Int = 0

    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        NavigationStack {
            VStack {
                RallyScore()
            }
            .containerBackground(Color.accentColor, for: .navigation)
            .toolbarColorScheme(.light, for: .automatic)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    SetScore()
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    if sessionManager.sessionData.winner == nil {
                        Button {
                            sessionManager.scoreTeam(designation: .A)
                        } label: {
                            Image(systemName: "plus.square.fill")
                        }
                    }

                    if sessionManager.sessionData.winner != nil {
                        Button {
                            sessionManager.reset()
                        } label: {
                            Image(systemName: "arrow.uturn.left")
                        }
                        .controlSize(.large)
                    }

                    if sessionManager.sessionData.winner == nil {
                        Button {
                            sessionManager.scoreTeam(designation: .B)
                        } label: {
                            Image(systemName: "plus.square.fill")
                        }
                    }
                }
            }
        }
        .foregroundStyle(.black)
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
    return LiveScore().environmentObject(sessionManager)
}
