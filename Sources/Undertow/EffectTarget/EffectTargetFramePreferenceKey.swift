//
//  EffectTargetFramePreferenceKey.swift
//  Undertow
//
//  Created by Maksim Gaisin on 03.08.26.
//

import SwiftUI

/// Collects each `.effectTarget()`'s mask geometry.
struct EffectTargetFramePreferenceKey: PreferenceKey {
    nonisolated(unsafe) static var defaultValue: Set<TargetMask> = []

    static func reduce(value: inout Set<TargetMask>, nextValue: () -> Set<TargetMask>) {
        value.formUnion(nextValue())
    }
}
