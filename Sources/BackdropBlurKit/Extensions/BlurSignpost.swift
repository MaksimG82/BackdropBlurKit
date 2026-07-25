//
//  BlurSignpost.swift
//  BackdropBlurKitExampleApp
//
//  Created by Maksim Gaisin on 29.06.26.
//


#if DEBUG
import os
import CoreGraphics
private let blurLog = OSLog(subsystem: "BackdropBlurKit", category: "Capture")

/// Marks the beginning of a named signpost interval during debug builds.
func blurSignpostBegin(_ name: StaticString) {
    os_signpost(.begin, log: blurLog, name: name)
}

/// Marks the end of a named signpost interval during debug builds.
func blurSignpostEnd(_ name: StaticString) {
    os_signpost(.end, log: blurLog, name: name)
}

/// Emits a point-in-time signpost event tagged with a scroll offset, during debug builds.
func blurSignpostEvent(_ name: StaticString, offset: CGPoint) {
    os_signpost(.event, log: blurLog, name: name, "x=%.2f y=%.2f", offset.x, offset.y)
}

/// Emits a point-in-time signpost event tagged with a timestamp, during debug builds.
func blurSignpostEvent(_ name: StaticString, time: CFTimeInterval) {
    os_signpost(.event, log: blurLog, name: name, "t=%.4f", time)
}
#else
@inline(__always) func blurSignpostBegin(_ name: StaticString) {}
@inline(__always) func blurSignpostEnd(_ name: StaticString) {}
@inline(__always) func blurSignpostEvent(_ name: StaticString, offset: CGPoint) {}
@inline(__always) func blurSignpostEvent(_ name: StaticString, time: CFTimeInterval) {}
#endif
