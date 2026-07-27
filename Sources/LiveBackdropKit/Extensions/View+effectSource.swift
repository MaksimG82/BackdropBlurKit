//
//  View+effectSource.swift
//  LiveBackdropKit
//
//  Created by Maksim Gaisin on 19.06.26.
//

import SwiftUI

public extension View {
    /// Designates this view hierarchy as the pixel and coordinate source for child visual effects.
    /// - Parameter navigationBarOverlap: Whether this capture region can ever overlap a
    ///   translucent navigation bar (including large-title/interactive-pop states). No
    ///   default — the call site must know its own screen structure.
    func effectSource(navigationBarOverlap: NavigationBarOverlap) -> some View {
        EffectSourceWrapper(navigationBarOverlap: navigationBarOverlap) { self }
    }
}

