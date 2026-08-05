//
//  View+invertedLayerEffect.swift
//  Undertow
//
//  Created by Maksim Gaisin on 03.08.26.
//

import SwiftUI

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
            ShaderLibrary.colorInversionTestLibrary.invertColors(),
            maxSampleOffset: .zero
        )
    }
}
