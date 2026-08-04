//
//  View+gaussianBlurLayerEffect.swift
//  LiveBackdropKit
//
//  Created by Maksim Gaisin on 04.08.26.
//

import SwiftUI

public extension View {
    /// Applies the single-pass, 9-tap Gaussian-approximation blur shader to this view via
    /// `.layerEffect` (see `GaussianBlur.metal` for the kernel and its known tradeoffs versus
    /// the CPU pipeline's `CIGaussianBlur`-backed `EffectConfiguration.gaussian`).
    /// - Parameter radius: The blur radius, in points. Also sets `maxSampleOffset` to
    ///   `CGSize(width: radius, height: radius)` — the shader's widest taps sit exactly
    ///   `radius` points from center on each axis, so `maxSampleOffset` must scale with
    ///   `radius` or the blur silently clips at the layer's edge.
    /// - Returns: This view with the Gaussian-approximation layer effect applied.
    @ViewBuilder
    func gaussianBlurLayerEffect(radius: CGFloat) -> some View {
        self.layerEffect(
            ShaderLibrary.liveBackdropKit.gaussianBlur(.float(radius)),
            maxSampleOffset: CGSize(width: radius, height: radius)
        )
    }
}
