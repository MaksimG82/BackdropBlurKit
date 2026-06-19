//
//  UIView+blurSource.swift
//  BackdropBlurKit
//
//  Created by Maksim Gaisin on 19.06.26.
//

import SwiftUI

public extension View {
    /// Designates this view hierarchy as the pixel and coordinate coordinate source for child blur effects.
    /// - Returns: A view prepared for real-time background tracking.
    func blurSource() -> some View {
        self.modifier(BlurSourceViewModifier())
    }
}

