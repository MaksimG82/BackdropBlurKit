//
//  View+effectSource.swift
//  Undertow
//
//  Created by Maksim Gaisin on 03.08.26.
//

import SwiftUI

public extension View {
    /// Applies an effect to this view, masked to the frames of descendant
    /// `.effectTarget()` views.
    /// - Parameter configuration: Which effect to apply. Defaults to `.invert`.
    /// - Returns: A view with the effect applied and masked to the collected target masks.
    func effectSource(configuration: Effect = .invert) -> some View {
        modifier(EffectSourceViewModifier(configuration: configuration))
    }
}
