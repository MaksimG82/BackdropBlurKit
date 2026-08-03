//
//  View+layerEffectTarget.swift
//  LiveBackdropKit
//
//  Created by Maksim Gaisin on 03.08.26.
//

import SwiftUI

public extension View {
    /// Marks the view as a target whose on-screen frame should be cut out of the nearest
    /// ancestor `.layerEffectSource()`'s effect.
    ///
    /// Reports this view's frame, in the global coordinate space, to the nearest ancestor
    /// `.layerEffectCoordinator()` via a `PreferenceKey`. This view itself renders nothing
    /// extra — it's the corresponding mask window inside `.layerEffectSource()` that becomes
    /// visible where this target sits.
    /// - Returns: A view that reports its frame for the GPU `.layerEffect` pipeline's masking.
    func layerEffectTarget() -> some View {
        modifier(LayerEffectTargetViewModifier())
    }
}
