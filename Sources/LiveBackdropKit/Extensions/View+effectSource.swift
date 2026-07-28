//
//  View+effectSource.swift
//  LiveBackdropKit
//
//  Created by Maksim Gaisin on 19.06.26.
//

import SwiftUI

public extension View {
    /// Designates this view hierarchy as the pixel and coordinate source for child visual effects.
    /// - Parameters:
    ///   - navigationBarOverlap: Whether this capture region can ever overlap a
    ///     translucent navigation bar (including large-title/interactive-pop states). No
    ///     default — the call site must know its own screen structure.
    ///   - captureMode: Which region to render when capturing a snapshot. Defaults to
    ///     `.unionFrame`, the production capture mode.
    func effectSource(navigationBarOverlap: NavigationBarOverlap, captureMode: CaptureMode = .unionFrame) -> some View {
        EffectSourceWrapper(navigationBarOverlap: navigationBarOverlap, captureMode: captureMode) { self }
    }
}

