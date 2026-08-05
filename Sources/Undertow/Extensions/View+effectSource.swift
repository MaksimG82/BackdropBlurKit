//
//  View+effectSource.swift
//  Undertow
//
//  Created by Maksim Gaisin on 03.08.26.
//

import SwiftUI

public extension View {
    /// Applies a GPU-based effect to this view, masked down to the frames of
    /// descendant `.effectTarget()` views collected via the nearest ancestor
    /// `.effectCoordinator()`.
    ///
    /// There's no capture, no snapshot, and no display-link-driven scheduling — the effect
    /// runs on every render pass automatically. One source drives exactly one `configuration` —
    /// there's no per-target override or environment-inherited default; running several effects
    /// on screen at once means several independent
    /// `effectSource()`/`effectTarget()`/`effectCoordinator()` trees.
    ///
    /// Wraps its content in a `GeometryReader`, which has no intrinsic size — apply any
    /// `.frame(...)` that sizes the scrolled content *after* this modifier, not before.
    /// - Parameters:
    ///   - configuration: Which GPU effect to apply. Defaults to `.invert`.
    ///   - cornerRadius: The corner radius applied to every target's mask window. Defaults to
    ///     `0`.
    /// - Returns: A view with the effect applied and masked to the collected target frames.
    func effectSource(
        configuration: Effect = .invert,
        cornerRadius: CGFloat = 0
    ) -> some View {
        modifier(EffectSourceViewModifier(configuration: configuration, cornerRadius: cornerRadius))
    }
}
