//
//  LayerEffectScenarioViewModel.swift
//  UndertowExampleApp
//
//  Created by Maksim Gaisin on 04.08.26.
//

import Foundation
import Observation
import Undertow

/// Owns a GPU `.layerEffect` scenario's applied `LayerEffectConfiguration` and `ScenarioBackground`,
/// so the same state can be read by the scenario's content (to render the effect/background) and
/// edited by its settings sheet (via `Binding`s), without needing separate, synchronized copies.
///
/// Shared across every `.layerEffectSource()` scenario — each screen creates and owns its own
/// instance (via `@State`), so scenarios don't share configuration with each other; only the
/// *shape* of the state is shared, since every such scenario needs exactly these two properties.
/// If a future scenario needs more state than this, give it a scenario-specific view model
/// instead of growing this one with scenario-specific fields.
@Observable
final class LayerEffectScenarioViewModel {

    /// The effect currently applied to the scenario's backdrop.
    var configuration: LayerEffectConfiguration = .gaussianBlur(radius: 10, maxSamples: 5)

    /// The background content currently rendered behind the scenario's effect/target views.
    var background: ScenarioBackground = .defaultCheckerboard

    /// The background kinds this scenario's settings sheet offers — set once at init based on
    /// whether the scenario's background scrolls (see `ScenarioBackground.photo`'s doc comment
    /// for why moving backgrounds exclude `.photo`).
    let availableBackgroundKinds: [ScenarioBackgroundKind]

    /// - Parameter isBackgroundMoving: Whether this scenario's background scrolls, which
    ///   restricts which background kinds are offered. Defaults to `false` (stationary
    ///   background, all kinds available).
    init(isBackgroundMoving: Bool = false) {
        availableBackgroundKinds = ScenarioBackgroundKind.availableKinds(forMovingBackground: isBackgroundMoving)
    }
}
