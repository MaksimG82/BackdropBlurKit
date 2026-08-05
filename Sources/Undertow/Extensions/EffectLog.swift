//
//  EffectLog.swift
//  Undertow
//
//  Created by Maksim Gaisin on 27.07.26.
//

import QuartzCore

/// Prints a `[LOG]`-tagged diagnostic line stamped with the current time.
///
/// Used to trace store mutations, target frame reporting, and source lifecycle events.
/// Intentionally left in place rather than stripped after debugging; see CLAUDE.md's
/// "Debug logging" section.
/// - Parameter event: A description of the event being logged.
func logEvent(_ event: String) {
//    print("[LOG] \(event), \(CACurrentMediaTime())")
}
