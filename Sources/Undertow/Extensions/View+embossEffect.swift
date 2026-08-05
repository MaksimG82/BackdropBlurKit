//
//  View+embossEffect.swift
//  Undertow
//
//  Created by Maksim Gaisin on 04.08.26.
//

import SwiftUI

public extension View {
    /// Applies the embossing/relief effect to this view via `.layerEffect` (see
    /// `Emboss.metal`).
    /// - Parameter strength: How strongly to add/subtract the offset pixels.
    /// - Returns: This view with the emboss effect applied.
    @ViewBuilder
    func embossEffect(strength: CGFloat) -> some View {
        self.layerEffect(
            ShaderLibrary.embossLibrary.emboss(.float(strength)),
            maxSampleOffset: CGSize(width: 1, height: 1)
        )
    }
}
