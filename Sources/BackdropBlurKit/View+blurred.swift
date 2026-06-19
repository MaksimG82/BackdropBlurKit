//
//  View+blurred.swift
//  BackdropBlurKit
//
//  Created by Maksim Gaisin on 19.06.26.
//

import SwiftUI

public extension View {
    /// Marks the view as a target to be overlaid with a backdrop blur effect.
    ///
    /// This modifier continuously tracks the view's global coordinates and transmits them up
    /// to the nearest ancestor `blurSource` container via preferences.
    ///
    /// - Parameter cornerRadius: The rounding radius of the blurred region's clipping mask. Defaults to `0`.
    /// - Returns: A view that automatically reports its positioning to the blur management system.
    func blurred(cornerRadius: CGFloat = 0) -> some View {
        modifier(BlurTargetViewModifier(cornerRadius: cornerRadius))
    }
}
