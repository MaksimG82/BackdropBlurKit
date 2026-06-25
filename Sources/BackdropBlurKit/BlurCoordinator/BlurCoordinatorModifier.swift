//
//  BlurCoordinatorModifier.swift
//  BackdropBlurKit
//
//  Created by Maksim Gaisin on 25.06.26.
//

import SwiftUI

/// A view modifier that collects processed snapshots from child `BlurSource` views
/// and distributes them to descendant `.blurred()` views via the environment.
struct BlurCoordinatorModifier: ViewModifier {

    /// The processed snapshots keyed by blur configuration.
    @State private var snapshots: [BlurConfiguration: UIImage] = [:]

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .environment(\.blurSourceSize, geometry.size)
                .onPreferenceChange(BlurSnapshotPreferenceKey.self) { newSnapshots in
                    print("snapshots received: \(newSnapshots.keys)")
                    snapshots = newSnapshots
                }
                .environment(\.blurSourceSnapshot, snapshots)
        }
        .ignoresSafeArea()
    }
}
