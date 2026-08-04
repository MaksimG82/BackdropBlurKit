//
//  View+layerEffectCoordinator.swift
//  LiveBackdropKit
//
//  Created by Maksim Gaisin on 03.08.26.
//

import SwiftUI

public extension View {
    /// Collects target frames from descendant `.layerEffectTarget()` views and distributes
    /// them to a descendant `.layerEffectSource()` via the environment.
    ///
    /// This is the GPU `.layerEffect`-based pipeline's coordinator — a fully separate
    /// mechanism from `effectCoordinator()`'s CPU-snapshot pipeline, sharing no state or types
    /// with it. `layerEffectCoordinator()` must wrap both `.layerEffectSource()` and any
    /// `.layerEffectTarget()` views for the environment plumbing to connect them.
    func layerEffectCoordinator() -> some View {
        modifier(LayerEffectCoordinatorModifier())
    }
}
