//
//  EffectScenarioViewModel.swift
//  UndertowExampleApp
//
//  Created by Maksim Gaisin on 04.08.26.
//

import Foundation
import Observation
import Undertow

/// Owns a scenario's applied `Effect` and `ScenarioBackground`,
@Observable
final class EffectScenarioViewModel {

    /// The effect currently applied to the scenario's backdrop.
    var configuration: Effect = .gaussianBlur(radius: 10, maxSamples: 5)

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
