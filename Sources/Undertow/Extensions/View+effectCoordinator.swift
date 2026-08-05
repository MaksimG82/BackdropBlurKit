//
//  View+effectCoordinator.swift
//  Undertow
//
//  Created by Maksim Gaisin on 03.08.26.
//

import SwiftUI

public extension View {
    /// Collects target frames from descendant `.effectTarget()` views and distributes
    /// them to a descendant `.effectSource()` via the environment.
    ///
    /// `effectCoordinator()` must wrap both `.effectSource()` and any
    /// `.effectTarget()` views for the environment plumbing to connect them.
    func effectCoordinator() -> some View {
        modifier(EffectCoordinatorModifier())
    }
}
