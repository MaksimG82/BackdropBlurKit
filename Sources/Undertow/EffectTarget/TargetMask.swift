//
//  TargetMask.swift
//  Undertow
//
//  Created by Maksim Gaisin on 05.08.26.
//

import CoreGraphics

/// A single `.effectTarget()`'s mask geometry: its frame plus its own corner radius.
struct TargetMask: Hashable {
    /// The target's frame, in the global coordinate space.
    let frame: CGRect

    /// The corner radius applied to this target's mask window.
    let cornerRadius: CGFloat
}
