//
//  View+colorPlanesLayerEffect.swift
//  Undertow
//
//  Created by Maksim Gaisin on 04.08.26.
//

import SwiftUI

public extension View {
    /// Applies the RGB-shift/glitch layer effect to this view via `.layerEffect` (see
    /// `ColorPlanes.metal`, adapted from Inferno's `ColorPlanes.metal`).
    /// - Parameter offset: How much to offset the red and blue channels by. The shader samples
    ///   up to `offset * 2` away from each pixel, so `maxSampleOffset` is set to double `offset`
    ///   to avoid clipping.
    /// - Returns: This view with the color-planes layer effect applied.
    @ViewBuilder
    func colorPlanesLayerEffect(offset: CGSize) -> some View {
        self.layerEffect(
            ShaderLibrary.liveBackdropKit.colorPlanes(.float2(Float(offset.width), Float(offset.height))),
            maxSampleOffset: CGSize(width: offset.width * 2, height: offset.height * 2)
        )
    }
}
