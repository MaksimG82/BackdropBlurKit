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

    /// The shared snapshot store owned by this coordinator and distributed to descendants via the environment.
    @State private var store = BlurSnapshotStore()

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .environment(\.blurSourceSize, geometry.size)
                .environment(\.blurSnapshotStore, store)
        }
        .ignoresSafeArea()
    }
}


@MainActor var _debugCaptureTime: CFAbsoluteTime = 0
