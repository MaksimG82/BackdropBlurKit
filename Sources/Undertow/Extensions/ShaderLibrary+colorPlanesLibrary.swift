//
//  ShaderLibrary+colorPlanesLibrary.swift
//  Undertow
//
//  Created by Maksim Gaisin on 05.08.26.
//

import SwiftUI

extension ShaderLibrary {
    /// The precompiled Metal shader library for the RGB-shift/glitch color-planes effect,
    /// selected based on the current runtime environment.
    static let colorPlanesLibrary: ShaderLibrary = {
#if targetEnvironment(simulator)
        let name = "ColorPlanes-iphonesimulator"
#else
        let name = "ColorPlanes-iphoneos"
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
