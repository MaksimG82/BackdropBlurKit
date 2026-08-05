//
//  View+embossLayerEffect.swift
//  Undertow
//
//  Created by Maksim Gaisin on 04.08.26.
//

import SwiftUI

public extension View {
    /// Applies the embossing/relief layer effect to this view via `.layerEffect` (see
    /// `Emboss.metal`, adapted from Inferno's `Emboss.metal`).
    /// - Parameter strength: How strongly to add/subtract the offset pixels.
    /// - Returns: This view with the emboss layer effect applied.
    @ViewBuilder
    func embossLayerEffect(strength: CGFloat) -> some View {
        self.layerEffect(
            ShaderLibrary.liveBackdropKit.emboss(.float(strength)),
            maxSampleOffset: CGSize(width: 1, height: 1)
        )
    }
}
