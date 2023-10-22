//
//  PulsingHeart.swift
//  Padel Pro
//
//  Created by Roland Kajatin on 19/10/2023.
//

import SwiftUI

struct PulsingHeart: View {
    var heartRate: Double
    var width: CGFloat = 20
    var height: CGFloat = 20
    
    @State private var animating = false

    var animationDuration: Double {
        if heartRate <= 0 {
            return 0.5
        }

        return 30.0 / heartRate
    }

    var body: some View {
        Heart()
            .frame(width: width, height: height)
            .foregroundColor(.red)
            .scaleEffect(animating ? 1.15 : 1)
            .shadow(color: .red.opacity(0.7), radius: 10)
            .animation(Animation.timingCurve(.circularEaseOut, duration: animationDuration).repeatForever(autoreverses: true), value: animating)
            .onAppear {
                DispatchQueue.main.async {
                    animating = true
                }
            }
    }
}

struct Heart: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))

        path.addCurve(to: CGPoint(x: rect.minX, y: rect.height/3),
                      control1: CGPoint(x: rect.midX - rect.width/4, y: rect.height*3/4),
                      control2: CGPoint(x: rect.minX, y: rect.height/2))

        path.addArc(center: CGPoint(x: rect.width/4, y: rect.height/4),
                    radius: (rect.width/4),
                    startAngle: Angle(radians: Double.pi),
                    endAngle: Angle(radians: 0),
                    clockwise: false)
        path.addArc(center: CGPoint(x: rect.width * 3/4, y: rect.height/4),
                    radius: (rect.width/4),
                    startAngle: Angle(radians: Double.pi),
                    endAngle: Angle(radians: 0),
                    clockwise: false)

        path.addCurve(to: CGPoint(x: rect.midX, y: rect.maxY),
                      control1: CGPoint(x: rect.width, y: rect.height/2),
                      control2: CGPoint(x: rect.midX + rect.width/4, y: rect.height*3/4))

        return path
    }
}

#Preview {
    PulsingHeart(heartRate: 60, width: 120, height: 120)
}
