//
//  View+whiteNoiseColorEffect.swift
//  Undertow
//
//  Created by Maksim Gaisin on 04.08.26.
//

import SwiftUI

public extension View {
    /// Applies the dynamic grayscale-noise effect to this view via `.colorEffect` (see
    /// `WhiteNoise.metal`, adapted from Inferno's `WhiteNoise.metal`).
    /// - Parameter time: Elapsed seconds since the effect's animation began.
    /// - Returns: This view with the white-noise color effect applied.
    @ViewBuilder
    func whiteNoiseColorEffect(time: TimeInterval) -> some View {
        self.colorEffect(
            ShaderLibrary.whiteNoiseLibrary.whiteNoise(.float(time))
        )
    }
}
