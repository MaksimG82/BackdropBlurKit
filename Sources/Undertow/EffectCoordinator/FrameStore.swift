//
//  FrameStore.swift
//  Undertow
//
//  Created by Maksim Gaisin on 03.08.26.
//

import SwiftUI

@Observable
/// A shared observable store that holds target frames reported by `.effectTarget()`
/// descendants.
final class FrameStore {
    /// Frames reported by all `.effectTarget()` targets, in the global coordinate space.
    /// Collected via standard SwiftUI `PreferenceKey` propagation
    /// (`EffectTargetFramePreferenceKey`).
    var targetFrames: Set<CGRect> = []
}
