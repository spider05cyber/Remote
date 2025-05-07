//
//  CrownPillView.swift
//  Remote
//
//  Created by Jayden Scarpa on 24/04/2025.
//

import SwiftUI
struct CrownPillView: View {
    var accumulator: Double
    let maxAmount: Double

    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let width = geometry.size.width
            let center = height / 2

            // Clamp accumulator to [-maxAmount, maxAmount]
            let clamped = max(-maxAmount, min(maxAmount, accumulator))
            let fillRatio = clamped / maxAmount

            ZStack {
                // Background
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: width, height: height)

                // Center line
                Rectangle()
                    .fill(Color.secondary)
                    .frame(width: width, height: 2)
                    .position(x: width / 2, y: center)

                // Fill from center out
                if fillRatio != 0 {
                    Rectangle()
                        .fill(Color.green)
                        .frame(
                            width: width,
                            height: abs(fillRatio) * center
                        )
                        .position(
                            x: width / 2,
                            y: center - (fillRatio > 0 ? (abs(fillRatio) * center) / 2 : -(abs(fillRatio) * center) / 2)
                        )
                        .mask(Capsule())
                }
            }
        }
        .frame(width: 8, height: 48)
    }
}

#Preview {
    CrownPillView(accumulator: 15, maxAmount: 55)
}
