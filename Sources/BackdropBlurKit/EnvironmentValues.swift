//
//  EnvironmentValues.swift
//  BackdropBlurKit
//
//  Created by Maksim Gaisin on 19.06.26.
//

import SwiftUI

extension EnvironmentValues {
    /// The background layer snapshot used by child views to apply a Metal-based blur effect.
    @Entry var blurSourceSnapshot: UIImage? = nil
}
