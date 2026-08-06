//
//  View+whiteNoiseEffect.swift
//  Undertow
//
//  Created by Maksim Gaisin on 04.08.26.
//

import SwiftUI

extension View {
    /// Applies the dynamic grayscale-noise effect to this view via `.colorEffect` (see
    /// `WhiteNoise.metal`).
    /// - Parameter time: Elapsed seconds since the effect's animation began.
    /// - Returns: This view with the white-noise effect applied.
    @ViewBuilder
    func whiteNoiseEffect(time: TimeInterval) -> some View {
        self.colorEffect(
            ShaderLibrary.whiteNoiseLibrary.whiteNoise(.float(time))
        )
    }
}
