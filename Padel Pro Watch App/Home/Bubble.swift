//
//  Bubble.swift
//  Padel Pro Watch App
//
//  Created by Roland Kajatin on 22/10/2023.
//

import SwiftUI

struct BubbleStack: View {
    var body: some View {
        ZStack {
            Bubble(scale: 0.85, rotation: -60, scaleEnd: 1.15, rotationEnd: 50, duration: 6)
                .foregroundColor(.blue)
                .opacity(0.2)
            Bubble(scale: 0.85, rotation: -120, scaleEnd: 1.15, rotationEnd: 50, duration: 10)
                .foregroundColor(.yellow)
                .opacity(0.1)
            Bubble(scale: 0.9, rotation: 90, scaleEnd: 1.1, rotationEnd: -90, duration: 8)
                .foregroundColor(.green)
                .opacity(0.1)
            Bubble(scale: 1, rotation: 60, scaleEnd: 0.9, rotationEnd: -50, duration: 12)
                .foregroundColor(.green)
                .opacity(0.2)
        }
    }
}

struct Bubble: View {
    @State var scale: Double
    @State var rotation: Double
    var scaleEnd: Double
    var rotationEnd: Double
    var duration: TimeInterval
    
    var body: some View {
        BubbleShape()
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    scale = scaleEnd
                    rotation = rotationEnd
                }
            }
    }
}

struct BubbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.19727*width, y: 0.16331*height))
        path.addLine(to: CGPoint(x: 0.10242*width, y: 0.31405*height))
        path.addCurve(to: CGPoint(x: 0.06747*width, y: 0.38947*height), control1: CGPoint(x: 0.08773*width, y: 0.33738*height), control2: CGPoint(x: 0.07598*width, y: 0.36275*height))
        path.addLine(to: CGPoint(x: 0.02536*width, y: 0.52176*height))
        path.addCurve(to: CGPoint(x: 0.14767*width, y: 0.89559*height), control1: CGPoint(x: -0.01933*width, y: 0.66214*height), control2: CGPoint(x: 0.03148*width, y: 0.81744*height))
        path.addLine(to: CGPoint(x: 0.22607*width, y: 0.94832*height))
        path.addCurve(to: CGPoint(x: 0.39318*width, y: 0.99545*height), control1: CGPoint(x: 0.27613*width, y: 0.98198*height), control2: CGPoint(x: 0.33438*width, y: 0.99841*height))
        path.addLine(to: CGPoint(x: 0.66763*width, y: 0.98162*height))
        path.addCurve(to: CGPoint(x: 0.92447*width, y: 0.78436*height), control1: CGPoint(x: 0.78128*width, y: 0.97589*height), control2: CGPoint(x: 0.88151*width, y: 0.8989*height))
        path.addLine(to: CGPoint(x: 0.97386*width, y: 0.65265*height))
        path.addCurve(to: CGPoint(x: 0.98955*width, y: 0.46916*height), control1: CGPoint(x: 0.99566*width, y: 0.59452*height), control2: CGPoint(x: 1.00112*width, y: 0.53067*height))
        path.addLine(to: CGPoint(x: 0.96569*width, y: 0.34232*height))
        path.addCurve(to: CGPoint(x: 0.8416*width, y: 0.14179*height), control1: CGPoint(x: 0.95026*width, y: 0.2603*height), control2: CGPoint(x: 0.90566*width, y: 0.18823*height))
        path.addLine(to: CGPoint(x: 0.72746*width, y: 0.05906*height))
        path.addCurve(to: CGPoint(x: 0.52503*width, y: 0.00881*height), control1: CGPoint(x: 0.66793*width, y: 0.0159*height), control2: CGPoint(x: 0.59589*width, y: -0.00198*height))
        path.addLine(to: CGPoint(x: 0.39775*width, y: 0.02818*height))
        path.addCurve(to: CGPoint(x: 0.19727*width, y: 0.16331*height), control1: CGPoint(x: 0.31642*width, y: 0.04056*height), control2: CGPoint(x: 0.24365*width, y: 0.08962*height))
        path.closeSubpath()
        return path
    }
}

#Preview {
    BubbleStack()
        .scenePadding()
}
