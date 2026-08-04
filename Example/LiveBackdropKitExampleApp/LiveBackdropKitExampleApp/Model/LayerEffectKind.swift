//
//  LayerEffectKind.swift
//  LiveBackdropKitExampleApp
//
//  Created by Maksim Gaisin on 04.08.26.
//

import CoreGraphics
import LiveBackdropKit

/// A parameter-less identifier for each `LayerEffectConfiguration` case, used to drive the
/// effect picker in a scenario's settings sheet. `LayerEffectConfiguration` itself can't back a
/// `Picker` directly — most of its cases carry associated values, so two selections of the same
/// case with different parameters wouldn't compare equal the way a `Picker` selection needs to.
enum LayerEffectKind: String, CaseIterable, Identifiable {
    case invert
    case gaussianBlur
    case colorPlanes
    case emboss
    case water
    case wave
    case shimmer
    case whiteNoise
    case rainbowNoise

    var id: Self { self }

    /// The display name shown in the effect picker.
    var title: String {
        switch self {
        case .invert: "Invert"
        case .gaussianBlur: "Gaussian Blur"
        case .colorPlanes: "Color Planes"
        case .emboss: "Emboss"
        case .water: "Water"
        case .wave: "Wave"
        case .shimmer: "Shimmer"
        case .whiteNoise: "White Noise"
        case .rainbowNoise: "Rainbow Noise"
        }
    }

    /// The kind backing a given configuration, for initializing the picker's selection from an
    /// existing `LayerEffectConfiguration`.
    init(_ configuration: LayerEffectConfiguration) {
        switch configuration {
        case .invert: self = .invert
        case .gaussianBlur: self = .gaussianBlur
        case .colorPlanes: self = .colorPlanes
        case .emboss: self = .emboss
        case .water: self = .water
        case .wave: self = .wave
        case .shimmer: self = .shimmer
        case .whiteNoise: self = .whiteNoise
        case .rainbowNoise: self = .rainbowNoise
        }
    }

    /// The default parameter values used when this kind is first selected in the effect
    /// picker. Cross-checked against Inferno (the shader library these effects are adapted
    /// from) where it provides a reference: `.water` and `.wave` match the starting values
    /// Inferno's own demo app (`TimeTransformationShader.shaders`) passes to those shaders;
    /// `.shimmer`'s duration/gradientWidth/maxLightness likewise match Inferno's demo values
    /// (its `angle` parameter has no Inferno counterpart — see `LayerEffectConfiguration`'s doc
    /// comment on `.shimmer` — so it keeps a value chosen for this library). `.colorPlanes` has
    /// no Inferno demo entry to check against, so its default is this library's own choice.
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
            .wave(speed: 5, smoothing: 10, strength: 5)
        case .shimmer:
            .shimmer(animationDuration: 3, gradientWidth: 0.3, maxLightness: 0.9, angle: 45)
        case .whiteNoise:
            .whiteNoise
        case .rainbowNoise:
            .rainbowNoise
        }
    }
}
