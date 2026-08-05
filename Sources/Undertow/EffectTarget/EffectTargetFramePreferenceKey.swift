//
//  EffectTargetFramePreferenceKey.swift
//  Undertow
//
//  Created by Maksim Gaisin on 03.08.26.
//

import SwiftUI

/// Collects each `.effectTarget()`'s frame (global coordinate space), bubbling up to the
/// nearest ancestor `.effectCoordinator()`. A standard SwiftUI multi-value `PreferenceKey`
/// merge — each target contributes its own single-element set, and `reduce` unions them all
/// together. Frames are masking geometry only, so identical frames from different targets
/// collapse harmlessly into one.
struct EffectTargetFramePreferenceKey: PreferenceKey {
    nonisolated(unsafe) static var defaultValue: Set<CGRect> = []

    static func reduce(value: inout Set<CGRect>, nextValue: () -> Set<CGRect>) {
        value.formUnion(nextValue())
    }
}
