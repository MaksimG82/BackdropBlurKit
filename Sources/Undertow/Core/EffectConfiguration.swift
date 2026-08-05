//
//  EffectConfiguration.swift
//  Undertow
//
//  Created by Maksim Gaisin on 04.08.26.
//

import SwiftUI

/// Defines the supported GPU-based visual effects and their parameters.
///
/// One configuration selects one effect for an `.effectSource()`. There's no per-target
/// override and no environment-inherited default — `.effectSource()` takes its configuration
/// directly, since one source drives exactly one effect; running several effects on screen at
/// once means several independent source/target/coordinator trees, which this pipeline already
/// supports naturally.
public enum EffectConfiguration: Hashable, Sendable {

    /// Inverts the sampled color's RGB channels. Originally a throwaway validation shader for
    /// proving out the GPU pipeline end to end; kept on as a real, permanent effect
    /// in its own right — see `invertedEffect()` and `ColorInversionTest.metal`.
    case invert

    /// A two-pass separable Gaussian blur adapted from Inferno's `VariableGaussianBlur.metal` —
    /// see `GaussianBlur.metal` for the shader and
    /// `gaussianBlurEffect(radius:boundingRect:maxSamples:)` for how the two passes are
    /// dispatched.
    /// - Parameters:
    ///   - radius: The blur radius, in points, applied uniformly to every pixel.
    ///   - maxSamples: The maximum number of samples to take in each direction from a pixel, per
    ///     axis pass. Lower values are cheaper; e.g. 5 is visually indistinguishable from 15 on
    ///     typical content while being noticeably lighter on scroll performance.
    case gaussianBlur(radius: CGFloat, maxSamples: Float)

    /// An RGB-shift/glitch effect that offsets the red and blue channels apart from green,
    /// adapted from Inferno's `ColorPlanes.metal` — see `ColorPlanes.metal` for the shader.
    /// - Parameter offset: How much to offset the red and blue channels by.
    case colorPlanes(offset: CGSize)

    /// An embossing/relief effect adapted from Inferno's `Emboss.metal` — see `Emboss.metal` for
    /// the shader.
    /// - Parameter strength: How strongly to add/subtract the offset pixels.
    case emboss(strength: CGFloat)

    /// A rippling water-distortion effect adapted from Inferno's `Water.metal` — see
    /// `Water.metal` for the shader and `waterEffect(size:time:speed:strength:frequency:)`
    /// for how it's applied. The first time-based case in this enum — see
    /// `EffectSourceViewModifier`, which wraps rendering in a `TimelineView(.animation)` only
    /// for cases like this one.
    /// - Parameters:
    ///   - speed: How fast the water ripples. 0.5–10 work best; try starting with 3.
    ///   - strength: How pronounced the rippling is. 1–5 work best; try starting with 3.
    ///   - frequency: How often ripples occur. 5–25 work best; try starting with 10.
    case water(speed: CGFloat, strength: CGFloat, frequency: CGFloat)

    /// A uniform wave-distortion effect adapted from Inferno's `Wave.metal` — see `Wave.metal`
    /// for the shader and `waveEffect(time:speed:smoothing:strength:)` for how it's applied.
    /// Offsets each pixel's Y position by an amount of its X position, unlike `.water`'s
    /// two-axis ripple.
    /// - Parameters:
    ///   - speed: How fast the waves ripple. Try starting with 5.
    ///   - smoothing: How much to smooth out the ripples; greater values produce a smoother
    ///     effect. Try starting with 20.
    ///   - strength: How pronounced the ripple effect is. Try starting with 5.
    case wave(speed: CGFloat, smoothing: CGFloat, strength: CGFloat)

    /// A shimmering gradient sweep adapted from Inferno's `Shimmer.metal` — see `Shimmer.metal`
    /// for the shader (note its header: the direction/angle support is a functional addition
    /// beyond Inferno's horizontal-only original) and
    /// `shimmerEffect(size:time:animationDuration:gradientWidth:maxLightness:direction:angle:)`
    /// for how it's applied.
    /// - Parameters:
    ///   - animationDuration: The duration of a single loop of the shimmer animation, in seconds.
    ///   - gradientWidth: The width of the shimmer gradient in UV space.
    ///   - maxLightness: The maximum lightness at the peak of the gradient.
    ///   - direction: The direction the gradient sweeps in, in degrees (0–360, 0 = rightward).
    ///   - angle: The orientation of the band itself, in degrees (0 = vertical; only meaningful
    ///     modulo 180°, independent of `direction`).
    case shimmer(animationDuration: CGFloat, gradientWidth: CGFloat, maxLightness: CGFloat, direction: CGFloat, angle: CGFloat)

    /// Dynamic, grayscale noise adapted from Inferno's `WhiteNoise.metal` — see
    /// `WhiteNoise.metal` for the shader.
    case whiteNoise

    /// Dynamic, multi-colored noise adapted from Inferno's `RainbowNoise.metal` — see
    /// `RainbowNoise.metal` for the shader.
    case rainbowNoise

    /// Whether this configuration needs a continuously-updating time value to animate, as
    /// opposed to rendering the same output for a fixed input. Used internally by
    /// `EffectSourceViewModifier` to decide whether to pay for a `TimelineView(.animation)`
    /// — skipped entirely for the static cases.
    var isTimeBased: Bool {
        switch self {
        case .invert, .gaussianBlur, .colorPlanes, .emboss:
            return false
        case .water, .wave, .shimmer, .whiteNoise, .rainbowNoise:
            return true
        }
    }
}
