//
//  LayerEffectCoordinatorModifier.swift
//  LiveBackdropKit
//
//  Created by Maksim Gaisin on 03.08.26.
//

import SwiftUI

/// A view modifier that collects target frames bubbling up from descendant
/// `.layerEffectTarget()` views via `LayerEffectTargetFramePreferenceKey` and distributes them
/// to a descendant `.layerEffectSource()` via the environment.
struct LayerEffectCoordinatorModifier: ViewModifier {
    /// The shared target-frame store owned by this coordinator and distributed to descendants via the environment.
    @State private var store = LayerEffectTargetStore()

    func body(content: Content) -> some View {
        content
            .environment(\.layerEffectTargetStore, store)
            .onPreferenceChange(LayerEffectTargetFramePreferenceKey.self) { store.targetFrames = $0 }
    }
}
