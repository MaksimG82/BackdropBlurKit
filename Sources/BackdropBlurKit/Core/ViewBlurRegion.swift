//
//  ViewBlurRegion.swift
//  BackdropBlurKit
//
//  Created by Maksim Gaisin on 19.06.26.
//

import SwiftUI

/// A geometric model that describes a specific interface region designated for a backdrop blur effect.
///
/// `ViewBlurRegion` captures the exact frame and visual rounding characteristics of a child view,
/// allowing the parent blurring container to pinpoint where the snapshot needs to be sampled and rendered.
struct ViewBlurRegion: Sendable, Hashable {
    /// The frame of the view in the global coordinate space.
    let frame: CGRect
    /// The corner radius of the view.
    let cornerRadius: CGFloat
}


