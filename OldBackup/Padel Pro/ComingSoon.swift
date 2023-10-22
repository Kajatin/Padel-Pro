//
//  ComingSoon.swift
//  Padel
//
//  Created by Roland Kajatin on 08/10/2023.
//

import SwiftUI

struct ComingSoon: View {
    var body: some View {
        GeometryReader { geometry in
            let wh = min(geometry.size.width * 0.8, geometry.size.height * 0.8)
            
            VStack(spacing: 20) {
                BubbleStack()
                    .frame(width: wh, height: wh)
                    .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
                
                Text("Coming soon to iPhone")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                
                Link(destination: URL(string: "https://apps.apple.com/us/app/padel-pro/id6469411547")!) {
                    HStack(alignment: .center) {
                        Text("Try on Apple Watch")
                        Image(systemName: "applewatch")
                    }
                }
                .font(.title2)
                .foregroundStyle(Color.accentColor)
            }
            .padding(.bottom)
        }
    }
}

#Preview {
    ComingSoon()
}
