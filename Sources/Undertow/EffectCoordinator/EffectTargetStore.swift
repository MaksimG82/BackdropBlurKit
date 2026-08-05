//
//  EffectTargetStore.swift
//  Undertow
//
//  Created by Maksim Gaisin on 03.08.26.
//

import SwiftUI

@Observable
/// A shared observable store that holds target frames reported by `.effectTarget()`
/// descendants.
final class EffectTargetStore {
    /// Frames reported by each `.effectTarget()` target, keyed by a stable per-target
    /// identity, in the global coordinate space. Collected via standard SwiftUI
    /// `PreferenceKey` propagation (`EffectTargetFramePreferenceKey`).
    var targetFrames: [UUID: CGRect] = [:]
}
