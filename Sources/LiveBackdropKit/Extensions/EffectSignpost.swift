//
//  EffectSignpost.swift
//  LiveBackdropKit
//
//  Created by Maksim Gaisin on 29.06.26.
//


import CoreGraphics

#if DEBUG
import os
private let effectLog = OSLog(subsystem: "LiveBackdropKit", category: "Capture")

/// Marks the beginning of a named signpost interval during debug builds.
func effectSignpostBegin(_ name: StaticString) {
    os_signpost(.begin, log: effectLog, name: name)
}

/// Marks the end of a named signpost interval during debug builds.
func effectSignpostEnd(_ name: StaticString) {
    os_signpost(.end, log: effectLog, name: name)
}

/// Emits a point-in-time signpost event tagged with a scroll offset, during debug builds.
func effectSignpostEvent(_ name: StaticString, offset: CGPoint) {
    os_signpost(.event, log: effectLog, name: name, "x=%.2f y=%.2f", offset.x, offset.y)
}

/// Emits a point-in-time signpost event tagged with a timestamp, during debug builds.
func effectSignpostEvent(_ name: StaticString, time: CFTimeInterval) {
    os_signpost(.event, log: effectLog, name: name, "t=%.4f", time)
}
#else
@inline(__always) func effectSignpostBegin(_ name: StaticString) {}
@inline(__always) func effectSignpostEnd(_ name: StaticString) {}
@inline(__always) func effectSignpostEvent(_ name: StaticString, offset: CGPoint) {}
@inline(__always) func effectSignpostEvent(_ name: StaticString, time: CFTimeInterval) {}
#endif
