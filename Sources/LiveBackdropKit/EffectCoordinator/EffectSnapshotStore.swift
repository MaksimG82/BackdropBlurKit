//
//  EffectSnapshotStore.swift
//  LiveBackdropKit
//
//  Created by Maksim Gaisin on 26.06.26.
//

import SwiftUI

@Observable
/// A shared observable store that holds processed effect snapshots keyed by configuration.
final class EffectSnapshotStore {
    /// The latest processed snapshots, updated by `EffectSource` and observed by `EffectTargetViewModifier`.
    var snapshots: [EffectConfiguration: UIImage] = [:] {
        didSet {
            logEvent("store.snapshots updated (\(snapshots.count) configuration(s))")
        }
    }

    /// Frames reported directly by each `.effectTarget()` target, keyed by a stable per-target
    /// identity. Written directly by `EffectTargetViewModifier` via `.onAppear`/`.onChange` —
    /// SwiftUI's `PreferenceKey` propagation proved unreliable for this exact view tree (nested
    /// `GeometryReader`s beside a `UIViewControllerRepresentable` sibling under
    /// `NavigationStack`: the ancestor's `.onPreferenceChange` would receive the initial default
    /// value and then never receive a subsequent update, leaving `captureRect` stuck at `.zero`
    /// indefinitely), so target frames are written directly to this shared store instead of
    /// being collected via `.preference()`/`.onPreferenceChange`.
    var targetFrames: [UUID: CGRect] = [:] {
        didSet {
            logEvent("store.targetFrames updated (\(targetFrames.count) target(s))")
            let resolved = Self.union(of: Array(targetFrames.values))
            guard resolved != captureRect else { return }
            captureRect = resolved
        }
    }

    /// The minimal rect enclosing all `.effectTarget()` target frames, in global/window coordinates.
    /// Derived automatically from `targetFrames` — set that instead of this directly.
    /// A value of `.zero` indicates no targets are registered yet — `EffectSource` skips capturing
    /// entirely while this is `.zero`, since nothing reads `snapshots` without a target to crop
    /// it against. Consumers that crop against a view's own local layer space (e.g.
    /// `EffectSource`) must first subtract that view's own window origin.
    private(set) var captureRect: CGRect = .zero {
        didSet {
            guard oldValue != captureRect else { return }
            logEvent("store.captureRect changed to \(captureRect)")
            onCaptureRectChanged?()
        }
    }

    /// Called when `captureRect` changes — signals `EffectSource` to re-capture immediately.
    var onCaptureRectChanged: (() -> Void)?

    /// The global-coordinate origin corresponding to pixel `(0, 0)` of the most recently
    /// delivered `snapshots` images. Written by `EffectSource.Coordinator` immediately before
    /// delivering a new snapshot. Distinct from `captureRect.origin`: `captureRect` is the
    /// *requested* crop region (the union of target frames), while `capturedOrigin` is where
    /// the delivered bitmap's own pixel origin actually landed once rendered — the two coincide
    /// under `CaptureMode.unionFrame` (the bitmap is cropped to `captureRect` by construction),
    /// but not under `.fullScreen`, where the bitmap covers the whole source view instead.
    /// `.effectTarget()` must offset against this, not `captureRect`, to stay correct across
    /// capture modes.
    var capturedOrigin: CGPoint = .zero

    // TEMP: lag investigation — remove after verification. Three display-link frame indices
    // that together let `.effectTarget()` log how many vsyncs elapsed between the source
    // content actually moving, the resulting snapshot being captured, and it being delivered.
    /// The display-link frame index as of the most recent tick, refreshed unconditionally on
    /// every tick regardless of whether a capture happened.
    var currentDisplayLinkFrame = 0
    /// The display-link frame index at which the most recently delivered snapshot was captured.
    var capturedFrameIndex = 0
    /// The display-link frame index of the last real `contentOffset` change reported by
    /// `ScrollTracker` — the "source content actually moved" signal.
    var lastScrollOffsetChangeFrame = 0

    /// Computes the minimal `CGRect` enclosing all given frames, or `.zero` if empty.
    private static func union(of frames: [CGRect]) -> CGRect {
        guard let first = frames.first else { return .zero }
        return frames.dropFirst().reduce(first) { $0.union($1) }
    }
}
