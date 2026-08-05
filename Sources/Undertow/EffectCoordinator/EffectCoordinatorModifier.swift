//
//  EffectCoordinatorModifier.swift
//  Undertow
//
//  Created by Maksim Gaisin on 03.08.26.
//

import SwiftUI

/// A view modifier that collects target masks bubbling up from descendant
/// `.effectTarget()` views via `EffectTargetFramePreferenceKey` and distributes them
/// to a descendant `.effectSource()` via the environment.
struct EffectCoordinatorModifier: ViewModifier {
    /// The shared mask store owned by this coordinator and distributed to descendants via the environment.
    @State private var store = MaskStore()

    func body(content: Content) -> some View {
        content
            .environment(\.maskStore, store)
            .onPreferenceChange(EffectTargetFramePreferenceKey.self) { store.targetMasks = $0 }
    }
}
