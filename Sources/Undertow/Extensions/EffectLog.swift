//
//  EffectLog.swift
//  Undertow
//
//  Created by Maksim Gaisin on 27.07.26.
//

import QuartzCore

/// Prints a `[LOG]`-tagged diagnostic line stamped with the current time.
///
/// Traces the capture pipeline — store mutations, target frame reporting, source lifecycle
/// events, and capture entry/exit — across `EffectSnapshotStore`, `EffectTargetViewModifier`, and
/// `EffectSource`. Intentionally left in place rather than stripped after debugging; see
/// CLAUDE.md's "Debug logging" section.
/// - Parameter event: A description of the event being logged.
func logEvent(_ event: String) {
//    print("[LOG] \(event), \(CACurrentMediaTime())")
}
