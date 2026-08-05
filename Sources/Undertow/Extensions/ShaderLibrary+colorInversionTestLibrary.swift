//
//  ShaderLibrary+colorInversionTestLibrary.swift
//  Undertow
//
//  Created by Maksim Gaisin on 05.08.26.
//

import SwiftUI

@available(iOS 17.0, *)
extension ShaderLibrary {
    /// The precompiled Metal shader library for the color-inversion test effect,
    /// selected based on the current runtime environment.
    static let colorInversionTestLibrary: ShaderLibrary = {
#if targetEnvironment(simulator)
        let name = "ColorInversionTest-iphonesimulator"
#else
        let name = "ColorInversionTest-iphoneos"
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
