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
    /// The modifier reads the blurred snapshot from the nearest ancestor `blurSource`
    /// and crops the region beneath this view to use as its backdrop.
    ///
    /// - Parameters:
    ///   - cornerRadius: The rounding radius of the blurred region's clipping mask. Defaults to `0`.
    ///   - blurConfiguration: An explicit blur configuration override. If `nil`, the value
    ///     from the environment is used. Defaults to `nil`.
    /// - Returns: A view that renders a live blurred backdrop behind itself.
    func blurred(
        cornerRadius: CGFloat = 0,
        blurConfiguration: BlurConfiguration? = nil
    ) -> some View {
        modifier(BlurTargetViewModifier(
            cornerRadius: cornerRadius,
            configurationOverride: blurConfiguration
        ))
    }
}
