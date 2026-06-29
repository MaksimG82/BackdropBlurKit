//
//  BlurSignpost.swift
//  BackdropBlurKitExampleApp
//
//  Created by Maksim Gaisin on 29.06.26.
//


#if DEBUG
import os
private let blurLog = OSLog(subsystem: "BackdropBlurKit", category: "Capture")

/// Marks the beginning of a named signpost interval during debug builds.
func blurSignpostBegin(_ name: StaticString) {
    os_signpost(.begin, log: blurLog, name: name)
}

/// Marks the end of a named signpost interval during debug builds.
func blurSignpostEnd(_ name: StaticString) {
    os_signpost(.end, log: blurLog, name: name)
}
#else
@inline(__always) func blurSignpostBegin(_ name: StaticString) {}
@inline(__always) func blurSignpostEnd(_ name: StaticString) {}
#endif
