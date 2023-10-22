//
//  StartView.swift
//  Padel Pro
//
//  Created by Roland Kajatin on 15/10/2023.
//

import OSLog
import SwiftUI
import HealthKit
import HealthKitUI

struct StartView: View {
    @State private var didStartWorkout = false
    @State private var triggerAuthorization = false
    
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        Group {
            if workoutManager.sessionState.isActive {
                MirroringWorkoutView()
            } else {
                VStack(alignment: .center) {
                    GeometryReader { geometry in
                        let wh = min(geometry.size.width * 0.8, geometry.size.height * 0.8)
                        BubbleStack()
                            .frame(width: wh, height: wh)
                            .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
                    }
                    
                    HStack(alignment: .center) {
                        Text("Launch workout on Apple Watch")
                        Image(systemName: "applewatch")
                    }
                    .font(.title2)
                    .foregroundStyle(.secondary)
                }
                .padding(.bottom)
                .healthDataAccessRequest(store: workoutManager.healthStore,
                                         shareTypes: workoutManager.typesToShare,
                                         readTypes: workoutManager.typesToRead,
                                         trigger: triggerAuthorization) { result in
                    switch result {
                    case .success(let success):
                        Logger.shared.debug("HealthKit authorization: \(success)")
                    case .failure(let error):
                        Logger.shared.error("Error authorizing HealthKit: \(error)")
                    }
                }
                 .onAppear() {
                     triggerAuthorization.toggle()
                     workoutManager.retrieveRemoteSession()
                 }
            }
        }
//        .onChange(of: workoutManager.sessionState) { _, newValue in
//            print("onchange: \(String(describing: workoutManager.session))")
//            didStartWorkout = newValue == .running
//        }
    }
}

#Preview {
    let workoutManager = WorkoutManager.shared
    return StartView()
        .environmentObject(workoutManager)
}
