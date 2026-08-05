//
//  View+effectCoordinator.swift
//  Undertow
//
//  Created by Maksim Gaisin on 25.06.26.
//

import SwiftUI

public extension View {
    /// Collects effect snapshots from child `EffectSource` views and distributes them
    /// to descendant `.effectTarget()` views via the environment.
    func effectCoordinator() -> some View {
        modifier(EffectCoordinatorModifier())
    }
}
