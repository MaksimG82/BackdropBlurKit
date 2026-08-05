//
//  View+shimmerEffect.swift
//  Undertow
//
//  Created by Maksim Gaisin on 04.08.26.
//

import SwiftUI

extension View {
    /// Applies the shimmering gradient-sweep effect to this view via `.colorEffect` (see
    /// `Shimmer.metal`).
    /// - Parameters:
    ///   - size: The size of this view, in its own local coordinate space.
    ///   - time: Elapsed seconds since the effect's animation began.
    ///   - animationDuration: The duration of a single loop of the shimmer animation, in seconds.
    ///   - gradientWidth: The width of the shimmer gradient in UV space.
    ///   - maxLightness: The maximum lightness at the peak of the gradient.
    ///   - direction: The direction the gradient sweeps in, in degrees (0–360, measured from the
    ///     x-axis, 0 = rightward) — converted to radians for the shader.
    ///   - angle: The orientation of the band itself, in degrees (0 = vertical, measured from the
    ///     y-axis; only meaningful modulo 180°) — converted to radians for the shader.
    /// - Returns: This view with the shimmer effect applied.
    @ViewBuilder
    func shimmerEffect(size: CGSize, time: TimeInterval, animationDuration: CGFloat, gradientWidth: CGFloat, maxLightness: CGFloat, direction: CGFloat, angle: CGFloat) -> some View {
        self.colorEffect(
            ShaderLibrary.shimmerLibrary.shimmer(
                .float2(size),
                .float(time),
                .float(animationDuration),
                .float(gradientWidth),
                .float(maxLightness),
                .float(direction * .pi / 180),
                .float(angle * .pi / 180)
            )
        )
    }
}
