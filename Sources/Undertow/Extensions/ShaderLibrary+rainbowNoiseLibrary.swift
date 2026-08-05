//
//  ShaderLibrary+rainbowNoiseLibrary.swift
//  Undertow
//
//  Created by Maksim Gaisin on 05.08.26.
//

import SwiftUI

extension ShaderLibrary {
    /// The precompiled Metal shader library for the dynamic multi-colored-noise effect.
    static let rainbowNoiseLibrary: ShaderLibrary = {
#if targetEnvironment(simulator)
        let name = "RainbowNoise-iphonesimulator"
#else
        let name = "RainbowNoise-iphoneos"
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
