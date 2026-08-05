//
//  LayerEffectTargetStore.swift
//  Undertow
//
//  Created by Maksim Gaisin on 03.08.26.
//

import SwiftUI

@Observable
/// A shared observable store that holds target frames reported by `.layerEffectTarget()`
/// descendants, for the GPU `.layerEffect`-based effect pipeline. Fully separate from
/// `EffectSnapshotStore` — no snapshots, no capture state, and no shared types with the CPU
/// pipeline.
final class LayerEffectTargetStore {
    /// Frames reported by each `.layerEffectTarget()` target, keyed by a stable per-target
    /// identity, in the global coordinate space. Collected via standard SwiftUI
    /// `PreferenceKey` propagation (`LayerEffectTargetFramePreferenceKey`), not the CPU
    /// pipeline's direct-write-to-shared-store workaround (see `EffectSnapshotStore.targetFrames`'s
    /// doc comment) — that workaround exists for a `UIViewControllerRepresentable`-under-
    /// `NavigationStack` failure mode that doesn't apply here, since `.layerEffectTarget()`'s
    /// tree is plain SwiftUI reporting from always-real, unconditional content. The underlying
    /// `PreferenceKey`-based reporting/reduce logic was verified empirically (simulator
    /// screenshot + console trace of frame propagation, on first appearance and across a
    /// non-zero scroll offset) in `LayerEffectTargetsScrollView`'s original local, ad-hoc
    /// prototype before being promoted into this public API unchanged; the promotion itself
    /// (this file, plus the coordinator/target/source modifiers) has not been independently
    /// re-run on-device — build and confirm in Xcode per this project's build policy before
    /// relying on it.
    var targetFrames: [UUID: CGRect] = [:]
}
