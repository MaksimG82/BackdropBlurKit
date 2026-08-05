//
//  EffectSourceViewModifier.swift
//  Undertow
//
//  Created by Maksim Gaisin on 03.08.26.
//

import SwiftUI

/// A view modifier that applies the shader for a given `Effect` to the view, masked to the
/// target masks.
///
/// Renders the content twice: once unaffected, and once with the effect applied and masked to
/// the collected target masks. Because the wrapping `GeometryReader` has no intrinsic size,
/// apply any `.frame(...)` that sizes the scrolled content *after* this modifier, not before.
struct EffectSourceViewModifier: ViewModifier {
    /// Which effect to apply.
    let configuration: Effect

    /// The shared mask store distributed by the nearest ancestor `.effectCoordinator()`.
    @Environment(\.maskStore) private var store

    /// The moment this modifier's view was created, used as the zero point for time-based
    /// configurations (e.g. `.water`) — see `effectLayer(content:boundingRect:)`. Unused, and
    /// costs nothing, for static configurations.
    @State private var startTime = Date.now

    private var targetMasks: Set<TargetMask> {
        store?.targetMasks ?? []
    }

    func body(content: Content) -> some View {
        GeometryReader { contentGeometry in
            let contentOrigin = contentGeometry.frame(in: .global).origin
            let boundingRect = CGRect(origin: .zero, size: contentGeometry.size)

            ZStack {
                content

                effectLayer(
                    content: content,
                    boundingRect: boundingRect)
                    .mask(
                        ZStack {
                            ForEach(Array(targetMasks), id: \.self) { mask in
                                RoundedRectangle(cornerRadius: mask.cornerRadius)
                                    .frame(width: mask.frame.width, height: mask.frame.height)
                                    .position(
                                        x: mask.frame.midX - contentOrigin.x,
                                        y: mask.frame.midY - contentOrigin.y
                                    )
                            }
                        }
                        .frame(width: contentGeometry.size.width, height: contentGeometry.size.height, alignment: .topLeading)
                    )
            }
        }
    }

    /// Renders the effect for `configuration`, wrapping in a `TimelineView(.animation)` only when
    /// `configuration.isTimeBased` — the single shared time source for every time-based effect in
    /// this pipeline, so adding another animated case later doesn't need its own frame source.
    /// Static configurations render once per SwiftUI update, same as before this existed.
    @ViewBuilder
    private func effectLayer(content: Content, boundingRect: CGRect) -> some View {
        if configuration.isTimeBased {
            TimelineView(.animation) { timeline in
                appliedEffect(
                    to: content,
                    boundingRect: boundingRect,
                    time: startTime.distance(to: timeline.date)
                )
            }
        } else {
            appliedEffect(to: content, boundingRect: boundingRect, time: 0)
        }
    }

    /// Dispatches to the shader-applying modifier for `configuration`.
    /// - Parameters:
    ///   - boundingRect: The content's bounds in its own local coordinate space, as measured by
    ///     the enclosing `GeometryReader` — passed through to shaders that need it (e.g. to reject
    ///     samples falling outside the view's edges, or to normalize UV coordinates).
    ///   - time: Elapsed seconds since `startTime`, for time-based configurations. Ignored by
    ///     static ones.
    @ViewBuilder
    private func appliedEffect(to content: Content, boundingRect: CGRect, time: TimeInterval) -> some View {
        switch configuration {
        case .invert:
            content.invertedEffect()
        case let .gaussianBlur(radius, maxSamples):
            content.gaussianBlurEffect(radius: radius, boundingRect: boundingRect, maxSamples: maxSamples)
        case let .colorPlanes(offset):
            content.colorPlanesEffect(offset: offset)
        case let .emboss(strength):
            content.embossEffect(strength: strength)
        case let .water(speed, strength, frequency):
            content.waterEffect(size: boundingRect.size, time: time, speed: speed, strength: strength, frequency: frequency)
        case let .wave(speed, smoothing, strength):
            content.waveEffect(time: time, speed: speed, smoothing: smoothing, strength: strength)
        case let .shimmer(animationDuration, gradientWidth, maxLightness, direction, angle):
            content.shimmerEffect(size: boundingRect.size, time: time, animationDuration: animationDuration, gradientWidth: gradientWidth, maxLightness: maxLightness, direction: direction, angle: angle)
        case .whiteNoise:
            content.whiteNoiseEffect(time: time)
        case .rainbowNoise:
            content.rainbowNoiseEffect(time: time)
        }
    }
}
