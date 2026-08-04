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

    private var targetFrames: [UUID: CGRect] {
        store?.targetFrames ?? [:]
    }

    func body(content: Content) -> some View {
        GeometryReader { contentGeometry in
            let contentOrigin = contentGeometry.frame(in: .global).origin

            ZStack {
                content

                appliedEffect(to: content)
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

    /// Dispatches to the shader-applying modifier for `configuration`.
    @ViewBuilder
    private func appliedEffect(to content: Content) -> some View {
        switch configuration {
        case .invert:
            content.invertedLayerEffect()
        case let .gaussianBlur(radius):
            content.gaussianBlurLayerEffect(radius: radius)
        }
    }
}
