//
//  Controls.swift
//  Padel Pro
//
//  Created by Roland Kajatin on 21/10/2023.
//

import SwiftUI

struct Controls: View {
    @Binding var showEndSheet: Bool

    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        GeometryReader { geometry in
            EndButton(showEndSheet: $showEndSheet)
                .opacity(workoutManager.sessionState == .paused ? 1 : 0)
                .position(x: geometry.frame(in: .local).minX + geometry.size.width * 0.16,
                          y: geometry.frame(in: .local).midY - 10)
            
            PauseResumeButton()
                .position(x: geometry.frame(in: .local).midX,
                          y: geometry.frame(in: .local).midY - 10)
        }
        .background(Color.background)
        .frame(height: 100)
    }
}

struct PauseResumeButton: View {
    @State var circleTapped = false
    @State var circlePressed = false
    
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        ZStack {
            Image(systemName: workoutManager.sessionState == .running ? "pause" : "arrow.clockwise")
                .font(.system(size: 40, weight: .light))
                .offset(x: circlePressed ? -90 : 0, y: circlePressed ? -90 : 0)
                .rotation3DEffect(Angle(degrees: circlePressed ? 20 : 0), axis: (x: 10, y: -10, z: 0))
        }
        .background(
            ZStack {
                Circle()
                    .fill(Color.background)
                    .frame(width: 100, height: 100)
                    .shadow(color: Color.lightShadow, radius: 4, x: -4, y: -4)
                    .shadow(color: Color.darkShadow, radius: 4, x: 4, y: 4)
            }
        )
        .scaleEffect(circleTapped ? 1.2 : 1)
        .onTapGesture (count: 1) {
            workoutManager.sessionState == .running ? workoutManager.session?.pause() : workoutManager.session?.resume()
            
            self.circleTapped.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.circleTapped = false
            }
        }
    }
}

struct EndButton: View {
    @State var circleTapped = false
    @State var circlePressed = false
    @Binding var showEndSheet: Bool
    
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        ZStack {
            Image(systemName: "xmark")
                .font(.system(size: 32, weight: .light))
                .offset(x: circlePressed ? -90 : 0, y: circlePressed ? -90 : 0)
                .rotation3DEffect(Angle(degrees: circlePressed ? 20 : 0), axis: (x: 10, y: -10, z: 0))
        }
        .background(
            ZStack {
                Circle()
                    .fill(Color.backgroundRed)
                    .frame(width: 70, height: 70)
                    .shadow(color: Color.lightShadowRed, radius: 4, x: -4, y: -4)
                    .shadow(color: Color.darkShadowRed, radius: 4, x: 4, y: 4)
            }
        )
        .scaleEffect(circleTapped ? 1.2 : 1)
        .onTapGesture (count: 1) {
            self.showEndSheet.toggle()
            self.circleTapped.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.circleTapped = false
            }
        }
    }
}

#Preview {
    @State var showEndSheet = false
    let workoutManager = WorkoutManager.shared
    return Controls(showEndSheet: $showEndSheet)
        .environmentObject(workoutManager)
}
