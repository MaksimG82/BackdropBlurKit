//
//  View+layerEffectCoordinator.swift
//  Undertow
//
//  Created by Maksim Gaisin on 03.08.26.
//

import SwiftUI

public extension View {
    /// Collects target frames from descendant `.layerEffectTarget()` views and distributes
    /// them to a descendant `.layerEffectSource()` via the environment.
    ///
    /// `layerEffectCoordinator()` must wrap both `.layerEffectSource()` and any
    /// `.layerEffectTarget()` views for the environment plumbing to connect them.
    func layerEffectCoordinator() -> some View {
        modifier(LayerEffectCoordinatorModifier())
    }
}
