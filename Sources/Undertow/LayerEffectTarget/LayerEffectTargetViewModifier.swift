//
//  LayerEffectTargetViewModifier.swift
//  Undertow
//
//  Created by Maksim Gaisin on 03.08.26.
//

import SwiftUI

/// A view modifier that measures the view's frame in the global coordinate space and reports
/// it via `LayerEffectTargetFramePreferenceKey`, for collection by the nearest ancestor
/// `.layerEffectCoordinator()` and use by its `.layerEffectSource()`.
struct LayerEffectTargetViewModifier: ViewModifier {
    /// A stable identity for this target, used to key its frame in the collected dictionary.
    /// Generated once and held for the view's lifetime.
    @State private var targetID = UUID()

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: LayerEffectTargetFramePreferenceKey.self,
                            value: [targetID: geometry.frame(in: .global)]
                        )
                }
            )
    }
}
