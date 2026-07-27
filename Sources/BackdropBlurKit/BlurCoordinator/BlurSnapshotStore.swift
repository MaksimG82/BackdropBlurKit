//
//  BlurSnapshotStore.swift
//  BackdropBlurKit
//
//  Created by Maksim Gaisin on 26.06.26.
//

import SwiftUI

@Observable
/// A shared observable store that holds processed blur snapshots keyed by configuration.
final class BlurSnapshotStore {
    /// The latest processed snapshots, updated by `BlurSource` and observed by `BlurTargetViewModifier`.
    var snapshots: [BlurConfiguration: UIImage] = [:]

    /// Frames reported directly by each `.blurred()` target, keyed by a stable per-target
    /// identity. Written directly by `BlurTargetViewModifier` via `.onAppear`/`.onChange` —
    /// SwiftUI's `PreferenceKey` propagation proved unreliable for this exact view tree (nested
    /// `GeometryReader`s beside a `UIViewControllerRepresentable` sibling under
    /// `NavigationStack`: the ancestor's `.onPreferenceChange` would receive the initial default
    /// value and then never receive a subsequent update, leaving `captureRect` stuck at `.zero`
    /// indefinitely), so target frames are written directly to this shared store instead of
    /// being collected via `.preference()`/`.onPreferenceChange`.
    var targetFrames: [UUID: CGRect] = [:] {
        didSet {
            let resolved = Self.union(of: Array(targetFrames.values))
            guard resolved != captureRect else { return }
            captureRect = resolved
        }
    }

    /// The minimal rect enclosing all `.blurred()` target frames, in global/window coordinates.
    /// Derived automatically from `targetFrames` — set that instead of this directly.
    /// A value of `.zero` indicates no targets are registered yet — `BlurSource` skips capturing
    /// entirely while this is `.zero`, since nothing reads `snapshots` without a target to crop
    /// it against. Consumers that crop against a view's own local layer space (e.g.
    /// `BlurSource`) must first subtract that view's own window origin.
    private(set) var captureRect: CGRect = .zero {
        didSet {
            guard oldValue != captureRect else { return }
            onCaptureRectChanged?()
        }
    }

    /// Called when `captureRect` changes — signals `BlurSource` to re-capture immediately.
    var onCaptureRectChanged: (() -> Void)?

    /// Computes the minimal `CGRect` enclosing all given frames, or `.zero` if empty.
    private static func union(of frames: [CGRect]) -> CGRect {
        guard let first = frames.first else { return .zero }
        return frames.dropFirst().reduce(first) { $0.union($1) }
    }
}
