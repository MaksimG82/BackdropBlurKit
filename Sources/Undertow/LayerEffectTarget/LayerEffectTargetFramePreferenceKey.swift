//
//  LayerEffectTargetFramePreferenceKey.swift
//  Undertow
//
//  Created by Maksim Gaisin on 03.08.26.
//

import SwiftUI

/// Collects each `.layerEffectTarget()`'s frame (global coordinate space), keyed by its
/// stable per-target identity, bubbling up to the nearest ancestor `.layerEffectCoordinator()`.
/// A standard SwiftUI multi-value `PreferenceKey` merge — each target contributes its own
/// single-entry dictionary, and `reduce` folds them all together.
struct LayerEffectTargetFramePreferenceKey: PreferenceKey {
    nonisolated(unsafe) static var defaultValue: [UUID: CGRect] = [:]

    static func reduce(value: inout [UUID: CGRect], nextValue: () -> [UUID: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}
