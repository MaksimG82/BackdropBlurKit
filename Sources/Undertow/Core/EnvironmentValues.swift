//
//  EnvironmentValues.swift
//  Undertow
//
//  Created by Maksim Gaisin on 19.06.26.
//

import SwiftUI

extension EnvironmentValues {
    /// The dictionary of processed snapshots keyed by the configuration used to produce them.
    ///
    /// Each target view looks up its own region's snapshot using the effect configuration
    /// that applies to it, then crops out the area beneath itself.
    @Entry var effectSourceSnapshot: [EffectConfiguration: UIImage] = [:]

    /// The effect configuration applied to an `effectSource` and inherited by its `effectTarget` descendants.
    ///
    /// Can be overridden at any point in the hierarchy via `.environment(\.effectConfiguration, ...)`,
    /// or per-view via the explicit parameter on `effectTarget(configuration:)`.
    @Entry var effectConfiguration: EffectConfiguration = .default

    /// The size of the `effectCoordinator`'s layout area, used to map global frames to snapshot coordinates.
    @Entry var effectSourceSize: CGSize = .zero

    /// The shared snapshot store distributed by the nearest ancestor `effectCoordinator`.
    @Entry var effectSnapshotStore: EffectSnapshotStore? = nil

    /// The shared target-frame store distributed by the nearest ancestor
    /// `layerEffectCoordinator`, for the GPU `.layerEffect`-based pipeline. Fully separate
    /// from `effectSnapshotStore` — no shared state with the CPU pipeline.
    @Entry var layerEffectTargetStore: LayerEffectTargetStore? = nil
}
