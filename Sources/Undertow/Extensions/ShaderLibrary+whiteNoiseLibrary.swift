//
//  ShaderLibrary+whiteNoiseLibrary.swift
//  Undertow
//
//  Created by Maksim Gaisin on 05.08.26.
//

import SwiftUI

extension ShaderLibrary {
    /// The precompiled Metal shader library for the dynamic grayscale-noise effect,
    /// selected based on the current runtime environment.
    static let whiteNoiseLibrary: ShaderLibrary = {
#if targetEnvironment(simulator)
        let name = "WhiteNoise-iphonesimulator"
#else
        let name = "WhiteNoise-iphoneos"
#endif
        guard
            let url = Bundle.module.url(
                forResource: name,
                withExtension: "metallib")
        else {
            fatalError("Undertow: missing Metal library '\(name).metallib' in bundle.")
        }
        return ShaderLibrary(url: url)
    }()
}
