//
//  BlurConfiguration.swift
//  BackdropBlurKit
//
//  Created by Maksim Gaisin on 19.06.26.
//

import SwiftUI

/// Defines the supported blur algorithms and their associated parameters.
public enum BlurConfiguration: Hashable, Sendable {

    /// A mathematically precise Gaussian blur.
    /// - Parameter radius: The radius of the blur for the Gaussian function calculation.
    case gaussian(radius: CGFloat)

    /// A high-performance, multi-pass Kawase blur.
    /// - Parameters:
    ///   - passes: The number of texture processing iterations.
    ///   - distance: The offset distance between pixel samples.
    case kawase(passes: Int, distance: CGFloat)

    /// The default blur configuration applied when no explicit override is provided.
    public static let `default`: BlurConfiguration = .gaussian(radius: 8)
}
