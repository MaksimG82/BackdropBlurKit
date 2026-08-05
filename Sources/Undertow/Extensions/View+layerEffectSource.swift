//
//  View+layerEffectSource.swift
//  Undertow
//
//  Created by Maksim Gaisin on 03.08.26.
//

import SwiftUI

public extension View {
    /// Applies a GPU `.layerEffect`-based effect to this view, masked down to the frames of
    /// descendant `.layerEffectTarget()` views collected via the nearest ancestor
    /// `.layerEffectCoordinator()`.
    ///
    /// A fully separate mechanism from `effectSource()`'s CPU-snapshot pipeline: there's no
    /// capture, no snapshot, and no display-link-driven scheduling — `.layerEffect` runs on
    /// every render pass automatically, so unlike `effectSource(navigationBarOverlap:captureMode:captureTrigger:captureExecution:)`,
    /// this takes no equivalent parameters. One source drives exactly one `configuration` —
    /// there's no per-target override or environment-inherited default the way
    /// `effectTarget(configuration:)` has one; running several effects on screen at once means
    /// several independent `layerEffectSource()`/`layerEffectTarget()`/`layerEffectCoordinator()`
    /// trees.
    ///
    /// Wraps its content in a `GeometryReader`, which has no intrinsic size — apply any
    /// `.frame(...)` that sizes the scrolled content *after* this modifier, not before.
    /// - Parameters:
    ///   - configuration: Which GPU layer effect to apply. Defaults to `.invert`.
    ///   - cornerRadius: The corner radius applied to every target's mask window. Defaults to
    ///     `0`.
    /// - Returns: A view with the effect applied and masked to the collected target frames.
    func layerEffectSource(
        configuration: LayerEffectConfiguration = .invert,
        cornerRadius: CGFloat = 0
    ) -> some View {
        modifier(LayerEffectSourceViewModifier(configuration: configuration, cornerRadius: cornerRadius))
    }
}
