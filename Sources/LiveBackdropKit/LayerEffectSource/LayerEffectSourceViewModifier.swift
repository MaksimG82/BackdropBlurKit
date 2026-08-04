//
//  LayerEffectSourceViewModifier.swift
//  LiveBackdropKit
//
//  Created by Maksim Gaisin on 03.08.26.
//

import SwiftUI

/// A view modifier that applies the shader for a given `LayerEffectConfiguration` to the view
/// and masks it down to the frames collected from descendant `.layerEffectTarget()` views
/// (read from the environment, as distributed by the nearest ancestor
/// `.layerEffectCoordinator()`).
///
/// Renders the content twice inside a `GeometryReader`: once unaffected (always visible,
/// everywhere — without this, masking the effect layer would also cut away the content itself
/// outside the mask windows), and once with the effect applied, masked to a single `ZStack` of
/// rounded rects — one per target frame — unioned into one `.mask(...)` composite pass rather
/// than one pass per target. Each mask shape is counter-scrolled against `contentGeometry`'s
/// own global-space origin so it stays visually pinned to its target's fixed screen position
/// while the content scrolls underneath. This is the confirmed structure/math from
/// `LayerEffectTargetsScrollView`'s prototype, ported as-is.
///
/// Because the wrapping `GeometryReader` has no intrinsic size, apply any `.frame(...)` that
/// sizes the scrolled content *after* this modifier, not before — the same placement
/// `GeometryReader` always needs inside a `ScrollView` to avoid collapsing to zero height.
struct LayerEffectSourceViewModifier: ViewModifier {
    /// Which GPU layer effect to apply — one configuration per source, dispatched via
    /// `appliedEffect(to:)` below. No per-target override: running several effects on screen
    /// means several independent source/target/coordinator trees.
    let configuration: LayerEffectConfiguration

    /// The corner radius applied to every target's mask window.
    let cornerRadius: CGFloat

    /// The shared target-frame store distributed by the nearest ancestor `layerEffectCoordinator`.
    @Environment(\.layerEffectTargetStore) private var store

    /// The moment this modifier's view was created, used as the zero point for time-based
    /// configurations (e.g. `.water`) — see `effectLayer(content:boundingRect:)`. Unused, and
    /// costs nothing, for static configurations.
    @State private var startTime = Date.now

    private var targetFrames: [UUID: CGRect] {
        store?.targetFrames ?? [:]
    }

    func body(content: Content) -> some View {
        GeometryReader { contentGeometry in
            let contentOrigin = contentGeometry.frame(in: .global).origin

            ZStack {
                content

                effectLayer(content: content, boundingRect: CGRect(origin: .zero, size: contentGeometry.size))
                    .mask(
                        ZStack {
                            ForEach(Array(targetFrames), id: \.key) { _, frame in
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .frame(width: frame.width, height: frame.height)
                                    .position(
                                        x: frame.midX - contentOrigin.x,
                                        y: frame.midY - contentOrigin.y
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
                appliedEffect(to: content, boundingRect: boundingRect, time: startTime.distance(to: timeline.date))
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
            content.invertedLayerEffect()
        case let .gaussianBlur(radius, maxSamples):
            content.gaussianBlurLayerEffect(radius: radius, boundingRect: boundingRect, maxSamples: maxSamples)
        case let .colorPlanes(offset):
            content.colorPlanesLayerEffect(offset: offset)
        case let .emboss(strength):
            content.embossLayerEffect(strength: strength)
        case let .water(speed, strength, frequency):
            content.waterDistortionEffect(size: boundingRect.size, time: time, speed: speed, strength: strength, frequency: frequency)
        case let .wave(speed, smoothing, strength):
            content.waveDistortionEffect(time: time, speed: speed, smoothing: smoothing, strength: strength)
        case let .shimmer(animationDuration, gradientWidth, maxLightness, angle):
            content.shimmerColorEffect(size: boundingRect.size, time: time, animationDuration: animationDuration, gradientWidth: gradientWidth, maxLightness: maxLightness, angle: angle)
        case .whiteNoise:
            content.whiteNoiseColorEffect(time: time)
        case .rainbowNoise:
            content.rainbowNoiseColorEffect(time: time)
        }
    }
}
