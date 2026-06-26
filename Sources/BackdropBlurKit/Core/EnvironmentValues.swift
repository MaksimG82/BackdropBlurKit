//
//  EnvironmentValues.swift
//  BackdropBlurKit
//
//  Created by Maksim Gaisin on 19.06.26.
//

import SwiftUI

extension EnvironmentValues {
    /// The dictionary of blurred snapshots keyed by the configuration used to produce them.
    ///
    /// Each target view looks up its own region's snapshot using the blur configuration
    /// that applies to it, then crops out the area beneath itself.
    @Entry var blurSourceSnapshot: [BlurConfiguration: UIImage] = [:]

    /// The blur configuration applied to a `blurSource` and inherited by its `blurred` descendants.
    ///
    /// Can be overridden at any point in the hierarchy via `.environment(\.blurConfiguration, ...)`,
    /// or per-view via the explicit parameter on `blurred(blurConfiguration:)`.
    @Entry var blurConfiguration: BlurConfiguration = .default
    
    /// The size of the `blurCoordinator`'s layout area, used to map global frames to snapshot coordinates.
    @Entry var blurSourceSize: CGSize = .zero

    /// The shared snapshot store distributed by the nearest ancestor `blurCoordinator`.
    @Entry var blurSnapshotStore: BlurSnapshotStore? = nil
}
