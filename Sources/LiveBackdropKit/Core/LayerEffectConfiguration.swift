//
//  LayerEffectConfiguration.swift
//  LiveBackdropKit
//
//  Created by Maksim Gaisin on 04.08.26.
//

import SwiftUI

/// Defines the supported GPU `.layerEffect`-based visual effects and their parameters.
///
/// Mirrors `EffectConfiguration` in spirit — one configuration selects one effect for a
/// `.layerEffectSource()` — but is a fully separate type: the two pipelines share no
/// configuration, shader, or dispatch code. Unlike `EffectConfiguration`, there's no
/// per-target override and no environment-inherited default — `.layerEffectSource()` takes
/// its configuration directly, since one source drives exactly one effect; running several
/// effects on screen at once means several independent source/target/coordinator trees, which
/// this pipeline already supports naturally.
public enum LayerEffectConfiguration: Hashable, Sendable {

    /// Inverts the sampled color's RGB channels. Originally a throwaway validation shader for
    /// proving out the `.layerEffect` pipeline end to end; kept on as a real, permanent effect
    /// in its own right — see `invertedLayerEffect()` and `ColorInversionTest.metal`.
    case invert

    /// A two-pass separable Gaussian blur adapted from Inferno's `VariableGaussianBlur.metal` —
    /// see `GaussianBlur.metal` for the shader and
    /// `gaussianBlurLayerEffect(radius:boundingRect:maxSamples:)` for how the two passes are
    /// dispatched.
    /// - Parameters:
    ///   - radius: The blur radius, in points, applied uniformly to every pixel.
    ///   - maxSamples: The maximum number of samples to take in each direction from a pixel, per
    ///     axis pass. Lower values are cheaper; e.g. 5 is visually indistinguishable from 15 on
    ///     typical content while being noticeably lighter on scroll performance.
    case gaussianBlur(radius: CGFloat, maxSamples: Float)
}
