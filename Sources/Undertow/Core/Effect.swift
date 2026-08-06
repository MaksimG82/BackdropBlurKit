//
//  Effect.swift
//  Undertow
//
//  Created by Maksim Gaisin on 04.08.26.
//

import SwiftUI

/// The supported visual effects and their parameters.
public enum Effect: Hashable, Sendable {

    /// Inverts the sampled color's RGB channels.
    case invert

    /// A two-pass separable Gaussian blur.
    /// - Parameters:
    ///   - radius: The blur radius, in points, applied uniformly to every pixel.
    ///   - maxSamples: The maximum number of samples to take in each direction from a pixel, per
    ///     axis pass. Lower values are cheaper; e.g. 5 is visually indistinguishable from 15 on
    ///     typical content while being noticeably lighter on scroll performance.
    case gaussianBlur(radius: CGFloat, maxSamples: Float)

    /// An RGB-shift/glitch effect that offsets the red and blue channels apart from green.
    /// - Parameter offset: How much to offset the red and blue channels by.
    case colorPlanes(offset: CGSize)

    /// An embossing/relief effect.
    /// - Parameter strength: How strongly to add/subtract the offset pixels.
    case emboss(strength: CGFloat)

    /// A rippling water-distortion effect.
    /// - Parameters:
    ///   - speed: How fast the water ripples. 0.5–10 work best; try starting with 3.
    ///   - strength: How pronounced the rippling is. 1–5 work best; try starting with 3.
    ///   - frequency: How often ripples occur. 5–25 work best; try starting with 10.
    case water(speed: CGFloat, strength: CGFloat, frequency: CGFloat)

    /// A uniform wave-distortion effect.
    /// - Parameters:
    ///   - speed: How fast the waves ripple. Try starting with 5.
    ///   - smoothing: How much to smooth out the ripples; greater values produce a smoother
    ///     effect. Try starting with 20.
    ///   - strength: How pronounced the ripple effect is. Try starting with 5.
    case wave(speed: CGFloat, smoothing: CGFloat, strength: CGFloat)

    /// A shimmering gradient sweep.
    /// - Parameters:
    ///   - animationDuration: The duration of a single loop of the shimmer animation, in seconds.
    ///   - gradientWidth: The width of the shimmer gradient in UV space.
    ///   - maxLightness: The maximum lightness at the peak of the gradient.
    ///   - direction: The direction the gradient sweeps in, in degrees (0–360, 0 = rightward).
    ///   - angle: The orientation of the band itself, in degrees (0 = vertical; only meaningful
    ///     modulo 180°, independent of `direction`).
    case shimmer(animationDuration: CGFloat, gradientWidth: CGFloat, maxLightness: CGFloat, direction: CGFloat, angle: CGFloat)

    /// Dynamic, grayscale noise.
    case whiteNoise

    /// Dynamic, multi-colored noise.
    case rainbowNoise

    /// Whether this effect needs a continuously-updating time value to animate, as opposed to
    /// rendering the same output for a fixed input. Used internally by
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
