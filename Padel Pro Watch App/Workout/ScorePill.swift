//
//  ScorePill.swift
//  Padel Pro Watch App
//
//  Created by Roland Kajatin on 15/06/2024.
//

import OSLog
import SwiftUI

struct ScorePill: View {
    @Environment(SessionManager.self) var sessionManager
    
    var winner: Team? = nil

    private let baseWidth: CGFloat = WKInterfaceDevice.current().screenBounds.width < 190 ? 42 : 50
    private let baseHeight: CGFloat = WKInterfaceDevice.current().screenBounds.width < 190 ? 24 : 26
    private let maxCrownRotation: Double = 300

    @State private var rotationValue: Double = 0
    @State private var rotationBasedWidth: CGFloat = WKInterfaceDevice.current().screenBounds.width < 190 ? 42 : 50
    @State private var rotationBasedHeight: CGFloat = WKInterfaceDevice.current().screenBounds.width < 190 ? 24 : 26
    @State private var rotationBasedWidthAway: CGFloat = WKInterfaceDevice.current().screenBounds.width < 190 ? 42 : 50
    @State private var rotationBasedHeightAway: CGFloat = WKInterfaceDevice.current().screenBounds.width < 190 ? 24 : 26
    @State private var crownDisabled: Bool = false

    private let scoreSize: CGFloat = WKInterfaceDevice.current().screenBounds.width < 190 ? 18 : 20

    var body: some View {
        ZStack {
            Color.offGray
                .frame(width: baseWidth, height: baseHeight)

            HStack(spacing: 0) {
                ZStack {
                    Capsule()
                        .frame(width: rotationBasedWidthAway, height: rotationBasedHeightAway)
                        .animation(.spring, value: rotationValue)
                        .foregroundStyle(.offGray)

                    if winner == .away {
                        Image(systemName: "crown")
                    } else if winner == nil {
                        let currentSet = sessionManager.match.currentSet()
                        if let tieBreaker = currentSet.tieBreaker {
                            Text("\(tieBreaker.points.teamAway)")
                                .foregroundStyle(.offBlack)
                        } else {
                            Text("\(currentSet.currentGame().points.teamAway.rawValue)")
                                .foregroundStyle(.offBlack)
                        }
                    } else {
                        Image(systemName: "xmark")
                    }
                }

                ZStack {
                    Capsule()
                        .frame(width: rotationBasedWidth, height: rotationBasedHeight)
                        .animation(.spring, value: rotationValue)
                        .foregroundStyle(.offWhite)
                    
                    
                    if winner == .home {
                        Image(systemName: "crown")
                            .foregroundStyle(.offBlack)
                    } else if winner == nil {
                        let currentSet = sessionManager.match.currentSet()
                        if let tieBreaker = currentSet.tieBreaker {
                            Text("\(tieBreaker.points.teamHome)")
                                .foregroundStyle(.offBlack)
                        } else {
                            Text("\(currentSet.currentGame().points.teamHome.rawValue)")
                                .foregroundStyle(.offBlack)
                        }
                    } else {
                        Image(systemName: "xmark")
                            .foregroundStyle(.offBlack)
                    }
                }
            }
        }
        .font(.system(size: scoreSize, weight: .bold, design: .monospaced))
        .focusable(true)
        .digitalCrownRotation($rotationValue, from: -maxCrownRotation, through: maxCrownRotation, sensitivity: .high, isContinuous: true, onChange: { event in
            if crownDisabled {
                return
            }

            if event.offset > 0 {
                rotationBasedWidthAway = nonLinearWidth(for: rotationValue)
                rotationBasedHeightAway = nonLinearHeight(for: rotationValue)
            } else {
                rotationBasedWidth = nonLinearWidth(for: rotationValue)
                rotationBasedHeight = nonLinearHeight(for: rotationValue)
            }

            if event.offset >= (0.9 * maxCrownRotation) || event.offset <= -(0.9 * maxCrownRotation) {
                withAnimation {
                    rotationValue = 0
                    rotationBasedWidth = baseWidth
                    rotationBasedHeight = baseHeight
                    rotationBasedWidthAway = baseWidth
                    rotationBasedHeightAway = baseHeight
                    crownDisabled = true
                    
                    let teamToScore = event.offset > 0 ? Team.away : Team.home
                    let matchOver = sessionManager.match.winner() != nil

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if matchOver {
                            sessionManager.reset()
                        } else {
                            sessionManager.score(for: teamToScore)
                        }
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        crownDisabled = false
                    }
                }
            }
        }, onIdle: {
            Task {
                try? await Task.sleep(for: .seconds(0.5))
                withAnimation {
                    rotationValue = 0
                    rotationBasedWidth = baseWidth
                    rotationBasedHeight = baseHeight
                    rotationBasedWidthAway = baseWidth
                    rotationBasedHeightAway = baseHeight
                }
            }
        })
    }

    private func nonLinearWidth(for value: Double) -> CGFloat {
        let relativeValue = abs(value) / maxCrownRotation
        let scaledValue = pow(relativeValue, 2)
        return baseWidth * (1 + 0.5 * scaledValue)
    }

    private func nonLinearHeight(for value: Double) -> CGFloat {
        return baseHeight
//        let relativeValue = abs(value) / maxCrownRotation
//        let scaledValue = pow(relativeValue, 2)
//        return baseHeight * (1 + 0.3 * scaledValue)
    }
}

#Preview {
    ScorePill(winner: .home)
        .environment(SessionManager())
}
