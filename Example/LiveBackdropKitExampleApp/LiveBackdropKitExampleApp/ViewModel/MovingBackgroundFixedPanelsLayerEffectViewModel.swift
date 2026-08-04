//
//  MovingBackgroundFixedPanelsLayerEffectViewModel.swift
//  LiveBackdropKitExampleApp
//
//  Created by Maksim Gaisin on 04.08.26.
//

import CoreGraphics
import Observation
import LiveBackdropKit

/// Owns `MovingBackgroundFixedPanelsLayerEffectView`'s scenario state — currently just the
/// applied `LayerEffectConfiguration` — so the same state can be read by the scenario's content
/// (to render the effect) and edited by its settings sheet (to change it), without the two
/// needing separate, synchronized copies.
///
/// Deliberately concrete, not protocol-abstracted over other scenarios' view models: each
/// scenario may end up with a different settings surface (e.g. CPU scenarios configure
/// `EffectConfiguration`, not `LayerEffectConfiguration`), and abstracting before a second or
/// third scenario's shape is known would guess at the wrong shared interface.
@Observable
final class MovingBackgroundFixedPanelsLayerEffectViewModel {

    /// The effect currently applied to the scenario's scrolling backdrop.
    var configuration: LayerEffectConfiguration = .gaussianBlur(radius: 10, maxSamples: 5)

    /// Switches to the given effect kind, replacing `configuration` with that kind's default
    /// parameters. Used by the settings sheet's effect picker — picking a kind and tuning its
    /// parameters are separate steps, so this only needs to seed reasonable starting values.
    func selectKind(_ kind: LayerEffectKind) {
        configuration = kind.defaultConfiguration
    }
}

extension LayerEffectKind {
    /// The default parameter values used when this kind is first selected in the effect
    /// picker. Time-based kinds (`.water`, `.wave`, `.shimmer`) use the starting values
    /// suggested in `LayerEffectConfiguration`'s own doc comments; the rest use values chosen
    /// to be clearly visible on the checkerboard backdrop without being overwhelming.
    var defaultConfiguration: LayerEffectConfiguration {
        switch self {
        case .invert:
            .invert
        case .gaussianBlur:
            .gaussianBlur(radius: 10, maxSamples: 5)
        case .colorPlanes:
            .colorPlanes(offset: CGSize(width: 6, height: 6))
        case .emboss:
            .emboss(strength: 4)
        case .water:
            .water(speed: 3, strength: 3, frequency: 10)
        case .wave:
            .wave(speed: 5, smoothing: 20, strength: 5)
        case .shimmer:
            .shimmer(animationDuration: 2, gradientWidth: 0.3, maxLightness: 0.8, angle: 45)
        case .whiteNoise:
            .whiteNoise
        case .rainbowNoise:
            .rainbowNoise
        }
    }
}
