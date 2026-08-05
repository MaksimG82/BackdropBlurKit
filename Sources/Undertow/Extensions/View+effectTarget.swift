//
//  View+effectTarget.swift
//  Undertow
//
//  Created by Maksim Gaisin on 19.06.26.
//

import SwiftUI

public extension View {
    /// Marks the view as a target to be overlaid with a live backdrop visual effect.
    ///
    /// The modifier reads the processed snapshot from the nearest ancestor `effectSource`
    /// and crops the region beneath this view to use as its backdrop.
    ///
    /// - Parameters:
    ///   - cornerRadius: The rounding radius of the effect region's clipping mask. Defaults to `0`.
    ///   - configuration: An explicit effect configuration override. If `nil`, the value
    ///     from the environment is used. Defaults to `nil`.
    /// - Returns: A view that renders a live backdrop effect behind itself.
    func effectTarget(
        cornerRadius: CGFloat = 0,
        configuration: EffectConfiguration? = nil
    ) -> some View {
        modifier(EffectTargetViewModifier(
            cornerRadius: cornerRadius,
            configurationOverride: configuration
        ))
    }
}
