//
//  CaptureMode.swift
//  LiveBackdropKit
//
//  Created by Maksim Gaisin on 28.07.26.
//

import Foundation

/// Which region `EffectSource` renders when capturing a snapshot. A measurement toggle for
/// comparing the cost of cropped vs. full-screen capture — both modes go through the same
/// render/process/deliver path and signposts, so `os_signpost` traces are directly comparable
/// between them.
public enum CaptureMode: Sendable {
    /// Crop to the union of all registered `.effectTarget()` frames (`EffectSnapshotStore.captureRect`).
    /// The default, production capture mode.
    case unionFrame
    /// Render the entire source view, ignoring `captureRect`. Brute-force baseline for measuring
    /// whether the union-frame crop is worth its added complexity.
    case fullScreen
}
