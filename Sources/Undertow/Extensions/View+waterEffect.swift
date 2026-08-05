//
//  View+waterEffect.swift
//  Undertow
//
//  Created by Maksim Gaisin on 04.08.26.
//

import SwiftUI

public extension View {
    /// Applies the water-ripple distortion effect to this view via `.distortionEffect` (see
    /// `Water.metal`, adapted from Inferno's `Water.metal`).
    /// - Parameters:
    ///   - size: The size of this view, in its own local coordinate space.
    ///   - time: Elapsed seconds since the effect's animation began.
    ///   - speed: How fast the water ripples. 0.5–10 work best.
    ///   - strength: How pronounced the rippling is. 1–5 work best.
    ///   - frequency: How often ripples occur. 5–25 work best.
    /// - Returns: This view with the water effect applied.
    @ViewBuilder
    func waterEffect(size: CGSize, time: TimeInterval, speed: CGFloat, strength: CGFloat, frequency: CGFloat) -> some View {
        self.distortionEffect(
            ShaderLibrary.waterLibrary.water(
                .float2(size),
                .float(time),
                .float(speed),
                .float(strength),
                .float(frequency)
            ),
            maxSampleOffset: .zero
        )
    }
}
