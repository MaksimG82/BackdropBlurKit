//
//  LayerEffectKind.swift
//  LiveBackdropKitExampleApp
//
//  Created by Maksim Gaisin on 04.08.26.
//

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
}
