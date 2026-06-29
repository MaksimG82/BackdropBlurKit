//
//  BlurTargetFramesPreferenceKey.swift
//  BackdropBlurKit
//
//  Created by Maksim Gaisin on 28.06.26.
//


import SwiftUI

/// Collects the global-space frames of all `.blurred()` target views
/// for the nearest ancestor `blurCoordinator` to compute a minimal capture region.
struct BlurTargetFramesPreferenceKey: PreferenceKey {
    /// An empty array as the default — no targets registered yet.
    nonisolated(unsafe) static var defaultValue: [CGRect] = []

    /// Merges frames from all `.blurred()` descendants into a single array.
    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}
