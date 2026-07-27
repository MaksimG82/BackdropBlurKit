//
//  NavigationBarOverlap.swift
//  LiveBackdropKit
//
//  Created by Maksim Gaisin on 25.07.26.
//

import Foundation

/// Whether this EffectSource's capture region can ever overlap a translucent
/// navigation bar (including large-title/interactive-pop states). No default —
/// the call site must know its own screen structure. Automatic detection is
/// deferred to a future change.
///
/// Deferred/NavigationStack-2.0: kept as public API for forward compatibility, but not
/// actively exercised or maintained while the plain-screen case (no `UINavigationController`)
/// is the priority.
public enum NavigationBarOverlap: Sendable {
    /// Never overlaps. Uses the fast `layer.render(in:)` path (~4ms).
    case none
    /// May overlap. Uses the slower but correct
    /// `drawHierarchy(afterScreenUpdates:)` path (~11-14ms).
    case possible
}
