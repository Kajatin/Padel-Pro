//
//  Onboarding.swift
//  Padel Pro Watch App
//
//  Created by Roland Kajatin on 19/06/2024.
//

import SwiftUI

struct Onboarding: View {
    @State private var selectedTab: OnboardingScreen? = .welcome

    var body: some View {
        TabView(selection: $selectedTab) {
            Welcome(tab: $selectedTab)
                .tag(.welcome as OnboardingScreen?)
            ScoreIntro()
                .tag(.scoreintro as OnboardingScreen?)
        }
    }
}

enum OnboardingScreen: Codable, Hashable, Identifiable, CaseIterable {
    case welcome
    case scoreintro

    var id: OnboardingScreen { self }
}

struct Welcome: View {
    @Binding var tab: OnboardingScreen?
    
    let textSize: CGFloat = WKInterfaceDevice.current().screenBounds.width < 190 ? 14 : 16
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .center, spacing: 12) {
                    Text("Welcome")
                        .font(.system(size: 18, weight: .black, design: .monospaced))
                    
                    Text("Let's get you started with Padel Pro.")
                        .font(.system(size: textSize, weight: .medium, design: .monospaced))
                }

                Spacer(minLength: 0)
                
                Button {
                    withAnimation {
                        tab = .scoreintro
                    }
                } label: {
                    Text("Continue")
                }
            }
            .scenePadding(.horizontal)
            .foregroundStyle(.offWhite)
            .containerBackground(.offBlack, for: .navigation)
        }
    }
}

struct ScoreIntro: View {
    @Environment(SessionManager.self) var sessionManager
    
    @AppStorage("isOnboarding") var isOnboarding: Bool?
    
    @State private var rotatedCrown = false
    
    let textSize: CGFloat = WKInterfaceDevice.current().screenBounds.width < 190 ? 12 : 14
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 12) {
                ScorePill()
                
                let points = sessionManager.match.currentSet().currentGame().points
                if points.teamAway == .love && points.teamHome == .love {
                    VStack {
                        Text("This view tracks the score of the game. Try rotating the digital crown to adjust the score.")
                            .font(.system(size: textSize, weight: .regular, design: .monospaced))
                        Spacer()
                    }
                } else {
                    VStack(alignment: .center, spacing: 6) {
                        Text("Nicely done!")
                            .font(.system(size: textSize, weight: .regular, design: .monospaced))
                        
                        Text("You are all set and ready to play.")
                            .font(.system(size: textSize, weight: .regular, design: .monospaced))
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                isOnboarding = false
                            }
                        } label: {
                            Text("Let's Go!")
                        }
                    }
                }
            }
            .scenePadding(.horizontal)
            .foregroundStyle(.offWhite)
            .containerBackground(.offBlack, for: .navigation)
        }
    }
}

#Preview {
    Onboarding()
        .environment(SessionManager())
}
