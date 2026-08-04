//
//  View+gaussianBlurLayerEffect.swift
//  LiveBackdropKit
//
//  Created by Maksim Gaisin on 04.08.26.
//

import SwiftUI

/// The fixed sample count used for every `gaussianBlurLayerEffect` pass — matches Inferno's own
/// default. Not exposed publicly; see `GaussianBlur.metal`'s `maxSamples` parameter doc.
private let gaussianBlurMaxSamples: Float = 15

public extension View {
    /// Applies the two-pass separable Gaussian blur shader to this view via `.layerEffect` (see
    /// `GaussianBlur.metal`, adapted from Inferno's `VariableGaussianBlur.metal`).
    ///
    /// Runs the shader twice in sequence — once along X, once along Y — since `.layerEffect`
    /// doesn't support multi-pass shaders in a single call.
    /// - Parameters:
    ///   - radius: The blur radius, in points, applied uniformly to every pixel.
    ///   - boundingRect: The bounding rectangle of this view in its own local coordinate space —
    ///     used to reject samples that fall outside the view's edges.
    /// - Returns: This view with the two-pass Gaussian blur layer effect applied.
    @ViewBuilder
    func gaussianBlurLayerEffect(radius: CGFloat, boundingRect: CGRect) -> some View {
        let boundingRectArg: SwiftUI.Shader.Argument = .float4(
            Float(boundingRect.origin.x),
            Float(boundingRect.origin.y),
            Float(boundingRect.width),
            Float(boundingRect.height)
        )

        self
            .layerEffect(
                ShaderLibrary.liveBackdropKit.gaussianBlur(
                    boundingRectArg,
                    .float(radius),
                    .float(gaussianBlurMaxSamples),
                    .float(0), // vertical: X pass
                    .float(1) // normalizeEdges
                ),
                maxSampleOffset: CGSize(width: radius, height: 0)
            )
            .layerEffect(
                ShaderLibrary.liveBackdropKit.gaussianBlur(
                    boundingRectArg,
                    .float(radius),
                    .float(gaussianBlurMaxSamples),
                    .float(1), // vertical: Y pass
                    .float(1) // normalizeEdges
                ),
                maxSampleOffset: CGSize(width: 0, height: radius)
            )
    }
}
