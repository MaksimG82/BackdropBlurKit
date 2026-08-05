//
//  View+waveDistortionEffect.swift
//  Undertow
//
//  Created by Maksim Gaisin on 04.08.26.
//

import SwiftUI

public extension View {
    /// Applies the uniform wave-distortion effect to this view via `.distortionEffect` (see
    /// `Wave.metal`, adapted from Inferno's `Wave.metal`).
    /// - Parameters:
    ///   - time: Elapsed seconds since the effect's animation began.
    ///   - speed: How fast the waves ripple. Try starting with 5.
    ///   - smoothing: How much to smooth out the ripples; greater values produce a smoother
    ///     effect. Try starting with 20.
    ///   - strength: How pronounced the ripple effect is. Try starting with 5.
    /// - Returns: This view with the wave distortion effect applied.
    @ViewBuilder
    func waveDistortionEffect(time: TimeInterval, speed: CGFloat, smoothing: CGFloat, strength: CGFloat) -> some View {
        self.distortionEffect(
            ShaderLibrary.waveLibrary.wave(
                .float(time),
                .float(speed),
                .float(smoothing),
                .float(strength)
            ),
            maxSampleOffset: .zero
        )
    }
}
