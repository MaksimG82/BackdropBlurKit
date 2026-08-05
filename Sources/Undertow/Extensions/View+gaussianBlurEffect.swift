//
//  View+gaussianBlurEffect.swift
//  Undertow
//
//  Created by Maksim Gaisin on 04.08.26.
//

import SwiftUI

extension View {
    /// Applies the two-pass separable Gaussian blur shader to this view via `.layerEffect` (see
    /// `GaussianBlur.metal`).
    ///
    /// Runs the shader twice in sequence — once along X, once along Y — since `.layerEffect`
    /// doesn't support multi-pass shaders in a single call.
    /// - Parameters:
    ///   - radius: The blur radius, in points, applied uniformly to every pixel.
    ///   - boundingRect: The bounding rectangle of this view in its own local coordinate space —
    ///     used to reject samples that fall outside the view's edges.
    ///   - maxSamples: The maximum number of samples to take in each direction from a pixel, per
    ///     axis pass.
    /// - Returns: This view with the two-pass Gaussian blur effect applied.
    @ViewBuilder
    func gaussianBlurEffect(radius: CGFloat, boundingRect: CGRect, maxSamples: Float) -> some View {
        let boundingRectArg: SwiftUI.Shader.Argument = .float4(
            Float(boundingRect.origin.x),
            Float(boundingRect.origin.y),
            Float(boundingRect.width),
            Float(boundingRect.height)
        )

        self
            .layerEffect(
                ShaderLibrary.gaussianBlurLibrary.gaussianBlur(
                    boundingRectArg,
                    .float(radius),
                    .float(maxSamples),
                    .float(0),
                    .float(1)
                ),
                maxSampleOffset: CGSize(width: radius, height: 0)
            )
            .layerEffect(
                ShaderLibrary.gaussianBlurLibrary.gaussianBlur(
                    boundingRectArg,
                    .float(radius),
                    .float(maxSamples),
                    .float(1),
                    .float(1)
                ),
                maxSampleOffset: CGSize(width: 0, height: radius)
            )
    }
}
