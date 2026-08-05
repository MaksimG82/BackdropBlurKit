//
//  EffectTargetViewModifier.swift
//  Undertow
//
//  Created by Maksim Gaisin on 03.08.26.
//

import SwiftUI

/// A view modifier that measures the view's frame in the global coordinate space and reports
/// it, together with `cornerRadius`, via `EffectTargetFramePreferenceKey`, for collection by
/// the nearest ancestor `.effectCoordinator()` and use by its `.effectSource()`.
struct EffectTargetViewModifier: ViewModifier {
    /// The corner radius applied to this target's mask window.
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: EffectTargetFramePreferenceKey.self,
                            value: [TargetMask(frame: geometry.frame(in: .global), cornerRadius: cornerRadius)]
                        )
                }
            )
    }
}
