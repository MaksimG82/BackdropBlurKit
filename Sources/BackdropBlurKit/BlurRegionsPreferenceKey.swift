//
//  BlurRegionsPreferenceKey.swift
//  BackdropBlurKit
//
//  Created by Maksim Gaisin on 19.06.26.
//

import SwiftUI

/// A preference key used to collect blur region data from child views up to their common ancestor container.
struct BlurRegionsPreferenceKey: PreferenceKey {
    /// The default value for the preference key, representing an empty list of blur regions.
    nonisolated(unsafe) static var defaultValue: [ViewBlurRegion] = []

    /// Reduces the sequence of preference values by appending new blur regions to the accumulated list.
    /// - Parameters:
    ///   - value: The accumulated list of blur regions passed up the view hierarchy.
    ///   - nextValue: A closure returning the next array of blur regions discovered in child views.
    static func reduce(value: inout [ViewBlurRegion], nextValue: () -> [ViewBlurRegion]) {
        value.append(contentsOf: nextValue())
    }
}

