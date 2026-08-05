//
//  View+effectSource.swift
//  Undertow
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
    ///   - captureTrigger: What triggers a capture while scrolling. Defaults to
    ///     `.tickSynchronized`, the original, regression-free behavior. See `CaptureTrigger`'s
    ///     doc comment for the v0.0.1 status of this and `captureExecution` together.
    ///   - captureExecution: How a triggered capture actually runs. Defaults to `.synchronous`.
    ///     See `CaptureExecution`.
    func effectSource(
        navigationBarOverlap: NavigationBarOverlap,
        captureMode: CaptureMode = .unionFrame,
        captureTrigger: CaptureTrigger = .tickSynchronized,
        captureExecution: CaptureExecution = .synchronous
    ) -> some View {
        EffectSourceWrapper(
            navigationBarOverlap: navigationBarOverlap,
            captureMode: captureMode,
            captureTrigger: captureTrigger,
            captureExecution: captureExecution
        ) { self }
    }
}

