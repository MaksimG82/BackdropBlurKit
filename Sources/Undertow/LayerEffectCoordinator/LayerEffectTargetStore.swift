//
//  LayerEffectTargetStore.swift
//  Undertow
//
//  Created by Maksim Gaisin on 03.08.26.
//

import SwiftUI

@Observable
/// A shared observable store that holds target frames reported by `.layerEffectTarget()`
/// descendants, for the GPU `.layerEffect`-based effect pipeline.
final class LayerEffectTargetStore {
    /// Frames reported by each `.layerEffectTarget()` target, keyed by a stable per-target
    /// identity, in the global coordinate space. Collected via standard SwiftUI
    /// `PreferenceKey` propagation (`LayerEffectTargetFramePreferenceKey`).
    var targetFrames: [UUID: CGRect] = [:]
}
