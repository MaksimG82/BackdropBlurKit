//
//  CaptureTrigger.swift
//  Undertow
//
//  Created by Maksim Gaisin on 30.07.26.
//

import Foundation

/// What triggers `EffectSource` to capture a new snapshot while scrolling.
///
/// v0.0.1 stopgap: three trigger/execution combinations were tried while chasing a
/// capture/delivery desync during fast scrolling (a visible seam vs. degraded scroll
/// smoothness), and none dominated cleanly — each trades one problem for the other
/// differently. Rather than commit to one "correct" default before there's more than one
/// effect to compare across, both this axis and `CaptureExecution` are exposed as
/// configuration. Only `.tickSynchronized` + `.synchronous` (the defaults) is validated as
/// regression-free; the other three combinations are implemented but not yet validated
/// against real content.
/// TODO: revisit systematically once there's more than one effect to compare across.
public enum CaptureTrigger: Sendable {
    /// Capture once per serviced `CADisplayLink` tick while scrolling is active (or a capture
    /// is otherwise pending). The original behavior — capture cadence is decoupled from the
    /// scroll view's own `contentOffset` updates, which can lag behind by up to a tick's worth
    /// of scroll distance during a fast fling (visible as a seam), but never runs nested
    /// inside UIKit's own scroll-handling call stack.
    case tickSynchronized
    /// Capture reactively, directly from each `ScrollTracker`-observed `contentOffset` change,
    /// instead of waiting for the next independently-clocked tick. Tighter geometry sync with
    /// the actual scroll position, at the cost of coupling capture cadence to scroll-event
    /// cadence — see `CaptureExecution` for why that matters for scroll smoothness.
    case onDemand
}
