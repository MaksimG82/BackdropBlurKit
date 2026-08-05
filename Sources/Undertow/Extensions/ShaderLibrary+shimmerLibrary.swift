//
//  ShaderLibrary+shimmerLibrary.swift
//  Undertow
//
//  Created by Maksim Gaisin on 05.08.26.
//

import SwiftUI

extension ShaderLibrary {
    /// The precompiled Metal shader library for the shimmering gradient-sweep effect.
    static let shimmerLibrary: ShaderLibrary = {
#if targetEnvironment(simulator)
        let name = "Shimmer-iphonesimulator"
#else
        let name = "Shimmer-iphoneos"
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
