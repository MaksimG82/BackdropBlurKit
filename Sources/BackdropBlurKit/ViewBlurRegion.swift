//
//  ViewBlurRegion.swift
//  BackdropBlurKit
//
//  Created by Maksim Gaisin on 19.06.26.
//

import SwiftUI

struct ViewBlurRegion: Sendable, Hashable {
    /// The frame of the view in the global coordinate space.
    let frame: CGRect
    /// The corner radius of the view.
    let cornerRadius: CGFloat
}
