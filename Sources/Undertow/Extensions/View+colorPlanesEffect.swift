//
//  View+colorPlanesEffect.swift
//  Undertow
//
//  Created by Maksim Gaisin on 04.08.26.
//

import SwiftUI

public extension View {
    /// Applies the RGB-shift/glitch effect to this view via `.layerEffect` (see
    /// `ColorPlanes.metal`.
    /// - Parameter offset: How much to offset the red and blue channels by. The shader samples
    ///   up to `offset * 2` away from each pixel, so `maxSampleOffset` is set to double `offset`
    ///   to avoid clipping.
    /// - Returns: This view with the color-planes effect applied.
    @ViewBuilder
    func colorPlanesEffect(offset: CGSize) -> some View {
        self.layerEffect(
            ShaderLibrary.colorPlanesLibrary.colorPlanes(.float2(Float(offset.width), Float(offset.height))),
            maxSampleOffset: CGSize(width: offset.width * 2, height: offset.height * 2)
        )
    }
}
