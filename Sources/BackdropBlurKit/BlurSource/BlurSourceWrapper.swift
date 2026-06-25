//
//  BlurSourceWrapper.swift
//  BackdropBlurKit
//
//  Created by Maksim Gaisin on 25.06.26.
//

import SwiftUI

/// A SwiftUI view that wraps `BlurSource` and reports processed snapshots
/// up the hierarchy via `BlurSnapshotPreferenceKey`.
struct BlurSourceWrapper<Content: View>: View {

    /// The background content to render in isolation.
    let content: () -> Content

    /// The current processed snapshots, updated by `BlurSource`.
    @State private var snapshots: [BlurConfiguration: UIImage] = [:]

    var body: some View {
        BlurSource(content: content, onProcessedSnapshot: { newSnapshots in
            snapshots = newSnapshots
        })
        .preference(key: BlurSnapshotPreferenceKey.self, value: snapshots)
    }
}
