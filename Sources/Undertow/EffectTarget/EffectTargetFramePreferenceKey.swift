//
//  EffectTargetFramePreferenceKey.swift
//  Undertow
//
//  Created by Maksim Gaisin on 03.08.26.
//

import SwiftUI

/// Collects each `.effectTarget()`'s mask geometry, bubbling up to the nearest ancestor
/// `.effectCoordinator()`. A standard SwiftUI multi-value `PreferenceKey` merge — each target
/// contributes its own single-element set, and `reduce` unions them all together. Identical
/// masks from different targets collapse harmlessly into one.
struct EffectTargetFramePreferenceKey: PreferenceKey {
    nonisolated(unsafe) static var defaultValue: Set<TargetMask> = []

    static func reduce(value: inout Set<TargetMask>, nextValue: () -> Set<TargetMask>) {
        value.formUnion(nextValue())
    }
}
