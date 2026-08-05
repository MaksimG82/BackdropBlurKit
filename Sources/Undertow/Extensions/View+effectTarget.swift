//
//  View+effectTarget.swift
//  Undertow
//
//  Created by Maksim Gaisin on 03.08.26.
//

import SwiftUI

public extension View {
    /// Marks the view as a target whose on-screen frame should be cut out of the nearest
    /// ancestor `.effectSource()`'s effect.
    /// - Parameter cornerRadius: The corner radius applied to this target's mask window.
    ///   Defaults to `0`.
    /// - Returns: A view that reports its frame for the effect pipeline's masking.
    func effectTarget(cornerRadius: CGFloat = 0) -> some View {
        modifier(EffectTargetViewModifier(cornerRadius: cornerRadius))
    }
}
