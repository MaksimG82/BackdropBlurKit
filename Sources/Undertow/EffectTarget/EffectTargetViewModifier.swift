//
//  EffectTargetViewModifier.swift
//  Undertow
//
//  Created by Maksim Gaisin on 03.08.26.
//

import SwiftUI

/// A view modifier that measures the view's frame in the global coordinate space and reports
/// it via `EffectTargetFramePreferenceKey`, for collection by the nearest ancestor
/// `.effectCoordinator()` and use by its `.effectSource()`.
struct EffectTargetViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: EffectTargetFramePreferenceKey.self,
                            value: [geometry.frame(in: .global)]
                        )
                }
            )
    }
}
