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

    /// A single-pass, 9-tap weighted approximation of a Gaussian blur — see
    /// `GaussianBlur.metal` for the kernel and why it isn't a true separable Gaussian, and
    /// `gaussianBlurLayerEffect(radius:)` for how `radius` drives sample spacing and
    /// `maxSampleOffset`.
    /// - Parameter radius: The blur radius, in points.
    case gaussianBlur(radius: CGFloat)
}
