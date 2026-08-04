//
//  View+shimmerColorEffect.swift
//  LiveBackdropKit
//
//  Created by Maksim Gaisin on 04.08.26.
//

import SwiftUI

public extension View {
    /// Applies the shimmering gradient-sweep effect to this view via `.colorEffect` (see
    /// `Shimmer.metal`, adapted from Inferno's `Shimmer.metal`).
    /// - Parameters:
    ///   - size: The size of this view, in its own local coordinate space.
    ///   - time: Elapsed seconds since the effect's animation began.
    ///   - animationDuration: The duration of a single loop of the shimmer animation, in seconds.
    ///   - gradientWidth: The width of the shimmer gradient in UV space.
    ///   - maxLightness: The maximum lightness at the peak of the gradient.
    ///   - angle: The sweep direction, in degrees (0–360) — converted to radians for the shader.
    /// - Returns: This view with the shimmer color effect applied.
    @ViewBuilder
    func shimmerColorEffect(size: CGSize, time: TimeInterval, animationDuration: CGFloat, gradientWidth: CGFloat, maxLightness: CGFloat, angle: CGFloat) -> some View {
        self.colorEffect(
            ShaderLibrary.liveBackdropKit.shimmer(
                .float2(size),
                .float(time),
                .float(animationDuration),
                .float(gradientWidth),
                .float(maxLightness),
                .float(angle * .pi / 180)
            )
        )
    }
}
