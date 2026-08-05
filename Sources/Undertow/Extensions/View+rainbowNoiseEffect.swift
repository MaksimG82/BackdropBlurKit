//
//  View+rainbowNoiseEffect.swift
//  Undertow
//
//  Created by Maksim Gaisin on 04.08.26.
//

import SwiftUI

public extension View {
    /// Applies the dynamic multi-colored-noise effect to this view via `.colorEffect` (see
    /// `RainbowNoise.metal`, adapted from Inferno's `RainbowNoise.metal`).
    /// - Parameter time: Elapsed seconds since the effect's animation began.
    /// - Returns: This view with the rainbow-noise effect applied.
    @ViewBuilder
    func rainbowNoiseEffect(time: TimeInterval) -> some View {
        self.colorEffect(
            ShaderLibrary.rainbowNoiseLibrary.rainbowNoise(.float(time))
        )
    }
}
