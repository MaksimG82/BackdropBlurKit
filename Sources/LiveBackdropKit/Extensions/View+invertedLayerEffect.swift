//
//  View+invertedLayerEffect.swift
//  LiveBackdropKit
//
//  Created by Maksim Gaisin on 03.08.26.
//

import SwiftUI

extension ShaderLibrary {
    /// The compiled Metal shader library bundled with this package, built from the `.metal`
    /// sources under `Sources/LiveBackdropKit/Metal/`.
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
    /// Applies the temporary `invertColors` validation shader to this view via `.layerEffect`.
    ///
    /// This exists only to validate the `.layerEffect` GPU pipeline end to end — Metal source
    /// compilation, `.metallib` resource bundling, `ShaderLibrary` loading, and shader
    /// application — ahead of building a real effect on the same plumbing. It is not part of
    /// the package's effect API (see `EffectConfiguration` for that), applies to the entire
    /// view with no masking or configuration, and should be removed once a real shader
    /// exercises this path.
    /// - Returns: This view with the color-inversion layer effect applied.
    @ViewBuilder
    func invertedLayerEffect() -> some View {
        self.layerEffect(
            ShaderLibrary.liveBackdropKit.invertColors(),
            maxSampleOffset: .zero
        )
    }
}
