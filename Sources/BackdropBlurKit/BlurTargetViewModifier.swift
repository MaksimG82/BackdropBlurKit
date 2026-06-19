//
//  BlurTargetViewModifier.swift
//  BackdropBlurKit
//
//  Created by Maksim Gaisin on 19.06.26.
//

import SwiftUI

/// A view modifier that measures the view's geometry in the global coordinate space and propagates it up the hierarchy.
struct BlurTargetViewModifier: ViewModifier {
    /// The custom corner radius to be applied to the blurred area.
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: BlurRegionsPreferenceKey.self,
                            value: [
                                ViewBlurRegion(
                                    frame: geometry.frame(in: .global),
                                    cornerRadius: cornerRadius
                                )
                            ]
                        )
                }
            )
    }
}


