//
//  View+invertedLayerEffect.swift
//  Undertow
//
//  Created by Maksim Gaisin on 03.08.26.
//

import SwiftUI

extension ShaderLibrary {
    /// The compiled Metal shader library bundled with this package, built from the `.metal`
    /// sources under `Sources/Undertow/Metal/`.
    ///
    /// SwiftPM's `resources: [.process("Metal")]` rule compiles those sources into a single
    /// `default.metallib` embedded in `Bundle.module`'s resource bundle — verified against
    /// both a simulator and a device build of this target; neither produces a
    /// platform-suffixed file name, so none is applied here.
    static var liveBackdropKit: ShaderLibrary {
        guard let url = Bundle.module.url(forResource: "default", withExtension: "metallib") else {
            fatalError("Missing default.metallib in Bundle.module — check the Metal resource build output.")
        }
        return ShaderLibrary(url: url)
    }
}

public extension View {
    /// Applies the `invertColors` shader to this view via `.layerEffect`.
    ///
    /// Originally written as a throwaway shader to validate the `.layerEffect` GPU pipeline
    /// end to end — Metal source compilation, `.metallib` resource bundling, `ShaderLibrary`
    /// loading, and shader application — ahead of building a real effect on the same plumbing.
    /// Kept on as a real, permanent effect in its own right: see
    /// `LayerEffectConfiguration.invert`, which dispatches to this from
    /// `.layerEffectSource(configuration:cornerRadius:)`. Applies to the entire view with no
    /// masking or configuration on its own — masking against target frames is
    /// `.layerEffectSource()`'s job, not this shader's.
    /// - Returns: This view with the color-inversion layer effect applied.
    @ViewBuilder
    func invertedLayerEffect() -> some View {
        self.layerEffect(
            ShaderLibrary.liveBackdropKit.invertColors(),
            maxSampleOffset: .zero
        )
    }
}
