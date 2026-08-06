//
//  View+invertedEffect.swift
//  Undertow
//
//  Created by Maksim Gaisin on 03.08.26.
//

import SwiftUI

extension View {
    /// Applies the `invertColors` shader to this view via `.layerEffect`.
    ///
    /// Applies to the entire view with no masking or configuration on its own — masking against
    /// target masks is `.effectSource()`'s job, not this shader's.
    /// - Returns: This view with the color-inversion effect applied.
    @ViewBuilder
    func invertedEffect() -> some View {
        self.layerEffect(
            ShaderLibrary.rgbInversionLibrary.invertColors(),
            maxSampleOffset: .zero
        )
    }
}
