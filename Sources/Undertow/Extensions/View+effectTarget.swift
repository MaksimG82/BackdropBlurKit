//
//  View+effectTarget.swift
//  Undertow
//
//  Created by Maksim Gaisin on 03.08.26.
//

import SwiftUI

public extension View {
    /// Marks the view as a target whose on-screen frame should be cut out of the nearest
    /// ancestor `.effectSource()`'s effect.
    ///
    /// Reports this view's frame, in the global coordinate space, to the nearest ancestor
    /// `.effectCoordinator()` via a `PreferenceKey`. This view itself renders nothing
    /// extra — it's the corresponding mask window inside `.effectSource()` that becomes
    /// visible where this target sits.
    /// - Parameter cornerRadius: The corner radius applied to this target's mask window.
    ///   Defaults to `0`.
    /// - Returns: A view that reports its frame for the effect pipeline's masking.
    func effectTarget(cornerRadius: CGFloat = 0) -> some View {
        modifier(EffectTargetViewModifier(cornerRadius: cornerRadius))
    }
}
