//
//  MaskStore.swift
//  Undertow
//
//  Created by Maksim Gaisin on 03.08.26.
//

import SwiftUI

/// A shared observable store that holds target masks reported by `.effectTarget()`
/// descendants.
@Observable
final class MaskStore {
    /// Masks reported by all `.effectTarget()` targets. Collected via standard SwiftUI
    /// `PreferenceKey` propagation (`EffectTargetFramePreferenceKey`).
    var targetMasks: Set<TargetMask> = []
}
