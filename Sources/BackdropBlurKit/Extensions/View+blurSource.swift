//
//  View+blurSource.swift
//  BackdropBlurKit
//
//  Created by Maksim Gaisin on 19.06.26.
//

import SwiftUI

public extension View {
    /// Designates this view hierarchy as the pixel and coordinate source for child blur effects.
    /// - Parameter navigationBarOverlap: Whether this capture region can ever overlap a
    ///   translucent navigation bar (including large-title/interactive-pop states). No
    ///   default — the call site must know its own screen structure.
    func blurSource(navigationBarOverlap: NavigationBarOverlap) -> some View {
        BlurSourceWrapper(navigationBarOverlap: navigationBarOverlap) { self }
    }
}

