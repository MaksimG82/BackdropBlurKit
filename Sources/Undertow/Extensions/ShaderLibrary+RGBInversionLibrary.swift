//
//  ShaderLibrary+RGBInversionLibrary.swift
//  Undertow
//
//  Created by Maksim Gaisin on 05.08.26.
//

import SwiftUI

extension ShaderLibrary {
    /// The precompiled Metal shader library for the color-inversion effect.
    static let rgbInversionLibrary: ShaderLibrary = {
#if targetEnvironment(simulator)
        let name = "RGBInversion-iphonesimulator"
#else
        let name = "RGBInversion-iphoneos"
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
