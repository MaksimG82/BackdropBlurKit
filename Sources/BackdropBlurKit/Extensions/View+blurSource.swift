//
//  View+blurSource.swift
//  BackdropBlurKit
//
//  Created by Maksim Gaisin on 19.06.26.
//

import SwiftUI

public extension View {
    /// Designates this view hierarchy as the pixel and coordinate source for child blur effects.
    func blurSource() -> some View {
        BlurSourceWrapper { self }
    }
}

