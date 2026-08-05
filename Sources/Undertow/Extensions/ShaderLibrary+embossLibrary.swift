//
//  ShaderLibrary+embossLibrary.swift
//  Undertow
//
//  Created by Maksim Gaisin on 05.08.26.
//

import SwiftUI

@available(iOS 17.0, *)
extension ShaderLibrary {
    /// The precompiled Metal shader library for the embossing/relief effect,
    /// selected based on the current runtime environment.
    static let embossLibrary: ShaderLibrary = {
#if targetEnvironment(simulator)
        let name = "Emboss-iphonesimulator"
#else
        let name = "Emboss-iphoneos"
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
