//
//  EffectSourceWrapper.swift
//  LiveBackdropKit
//
//  Created by Maksim Gaisin on 25.06.26.
//

import SwiftUI

/// A SwiftUI view that wraps `EffectSource` and reports processed snapshots
/// up the hierarchy via the shared `EffectSnapshotStore`.
struct EffectSourceWrapper<Content: View>: View {

    /// Whether this capture region can ever overlap a translucent navigation bar.
    let navigationBarOverlap: NavigationBarOverlap

    /// Which region to render when capturing a snapshot — cropped to the union of target
    /// frames, or the full source view.
    let captureMode: CaptureMode

    /// What triggers a capture while scrolling. See `CaptureTrigger`'s doc comment for the
    /// v0.0.1 status of this and `captureExecution` together.
    let captureTrigger: CaptureTrigger

    /// How a triggered capture actually runs. See `CaptureExecution`.
    let captureExecution: CaptureExecution

    /// The background content to render in isolation.
    let content: () -> Content

    /// The current processed snapshots, updated by `EffectSource`.
    @State private var snapshots: [EffectConfiguration: UIImage] = [:]

    /// The shared snapshot store received from the nearest ancestor `effectCoordinator`.
    @Environment(\.effectSnapshotStore) private var store

    var body: some View {
        EffectSource(
            navigationBarOverlap: navigationBarOverlap,
            captureMode: captureMode,
            captureTrigger: captureTrigger,
            captureExecution: captureExecution,
            content: content,
            onProcessedSnapshot: { newSnapshots in
                store?.snapshots = newSnapshots
            }
        )
    }
}
