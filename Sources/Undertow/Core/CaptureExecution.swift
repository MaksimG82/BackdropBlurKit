//
//  CaptureExecution.swift
//  Undertow
//
//  Created by Maksim Gaisin on 30.07.26.
//

import Foundation

/// How `EffectSource` runs a capture once triggered (see `CaptureTrigger`).
///
/// Orthogonal to `CaptureTrigger` — see that type's doc comment for the v0.0.1 status of
/// these two axes together.
public enum CaptureExecution: Sendable {
    /// Run the capture inline, synchronously, on whatever call triggered it. Safe when the
    /// trigger is an independent display-link tick; if the trigger is `.onDemand`, this runs
    /// nested inside UIKit's own `contentOffset`-mutating call and can measurably block it,
    /// degrading scroll smoothness.
    case synchronous
    /// Defer the capture via `DispatchQueue.main.async`, coalesced to at most one pending
    /// capture at a time. Avoids blocking whatever triggered it, at the cost of the capture
    /// landing one run-loop turn later than the trigger.
    case asynchronous
}
